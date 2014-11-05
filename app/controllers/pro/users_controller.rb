# encoding: utf-8
class Pro::UsersController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  layout 'admin'

  authorize_resource :users

  def index
    if params[:with_comments]
      @users = UserSearch.search(active: true, has_comments: true, page: params[:page], name: params[:name]).results
    elsif params[:inactive]
      @users = UserSearch.search(active: true, has_confirmed: false, page: params[:page], name: params[:name]).results
    else
      @users = UserSearch.search(active: true, page: params[:page], name: params[:name]).results
    end
    @users_per_hour = { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0, 13 => 0, 14 => 0, 15 => 0, 16 => 0, 17 => 0, 18 => 0, 19 => 0, 20 => 0, 21 => 0, 22 => 0, 23 => 0 }
    User.active.find_each do |user|
      @users_per_hour[user.created_at.hour] += 1
    end

    mc_arel = Mailboxer::Conversation.arel_table
    @messages_graph = Mailboxer::Conversation.where(mc_arel[:created_at].gt(1.months.ago).and(
                                                    mc_arel[:mailboxer_label_id].eq_any([1,4])))
                                                   .order("DATE(created_at) ASC").group("DATE(created_at)").count
    @users_graph = User.where(User.arel_table[:created_at].gt(1.months.ago) ).active
                       .order("DATE(created_at) ASC").group("DATE(created_at)").count


    dates = (1.month.ago.to_date..Date.today).step
    @users_cumul = {}
    dates.each do |date|
      @users_graph[date]    ||= 0
      @messages_graph[date] ||= 0
      @users_cumul[date] = User.active.where(User.arel_table[:created_at].lt(date + 1.day)).count
    end

    @messages_cumul = {}
    dates.each do |date|
      @messages_cumul[date] = Mailboxer::Conversation.where(mc_arel[:mailboxer_label_id].eq_any([1,4]).and(mc_arel[:created_at].lt(date + 1.day))).count
    end

    respond_to do |format|
      format.html
      format.json { render json: @users }
      format.csv { render text: User.order('created_at DESC').limit(params[:limit] || 300).offset(params[:offset] || 0).to_csv }
    end
  end

  def activate
    @user = User.find params[:id]
    @user.confirm!
    redirect_to pro_users_path
  end
end
