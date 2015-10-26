# encoding: utf-8
class Admin::UsersController < Admin::AdminController

  def update
    @user = User.find(params[:id])
    @user.pass_comment =  params[:user][:pass_comment]
    @user.save
    redirect_to pass_admin_users_path
  end

  def pass
    @users = User.where("meta_data -> 'test_pass_subject' LIKE '%'")
  end

  def index
    if params[:name].present?
      @users = User.where(User.arel_table[:email].matches("%#{params[:name]}%")
                          .or(User.arel_table[:first_name].matches("%#{params[:name]}%"))
                          .or(User.arel_table[:last_name].matches("%#{params[:name]}%")))
    else
      @users = User.page(params[:page])
    end
    mc_arel = Mailboxer::Conversation.arel_table
    @messages_graph = Mailboxer::Conversation.where(mc_arel[:created_at].gt(1.months.ago).and(
                                                    mc_arel[:mailboxer_label_id].eq_any([1,4])))
                                                   .order("DATE(created_at) ASC").group("DATE(created_at)").count
    @users_graph = User.where(User.arel_table[:sign_up_at].gt(1.months.ago) ).active
                       .order("DATE(sign_up_at) ASC").group("DATE(sign_up_at)").count


    @dates = (1.month.ago.to_date..Date.today).step
    @users_cumul = {}
    @dates.each do |date|
      @users_graph[date]    ||= 0
      @messages_graph[date] ||= 0
      @users_cumul[date] = User.active.where(User.arel_table[:sign_up_at].lt(date + 1.day)).count
    end

    @messages_cumul = {}
    @dates.each do |date|
      @messages_cumul[date] = Mailboxer::Conversation.where(mc_arel[:mailboxer_label_id].eq_any([1,4]).and(mc_arel[:created_at].lt(date + 1.day))).count
    end

    respond_to do |format|
      format.html
      format.json { render json: @users }
      format.csv { render text: User.order('sign_up_at DESC').limit(params[:limit] || 300).offset(params[:offset] || 0).to_csv }
    end
  end

end
