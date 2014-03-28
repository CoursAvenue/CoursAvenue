# encoding: utf-8
class Pro::UsersController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  layout 'admin'

  authorize_resource :users

  def index
    if params[:with_comments]
      @users = User.active.joins { comments }.where { comments.user_id == users.id }.order('updated_at DESC, created_at DESC').limit(100)
    elsif params[:inactive]
      @users = User.active.where{confirmed_at == nil}.order('updated_at DESC, created_at DESC')
    else
      @users = User.active.order('updated_at DESC, created_at DESC').limit(100)
    end
    @users_per_hour = { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0, 13 => 0, 14 => 0, 15 => 0, 16 => 0, 17 => 0, 18 => 0, 19 => 0, 20 => 0, 21 => 0, 22 => 0, 23 => 0 }
    User.active.find_each do |user|
      @users_per_hour[user.created_at.hour] += 1
    end

    @users_graph = User.where{created_at > 2.months.ago}.active.count(order: "DATE(created_at) ASC", group: ["DATE(created_at)"])
    dates = (1.month.ago.to_date..Date.today).step
    @users_cumul = {}
    dates.each do |date|
      @users_cumul[date] = User.active.where { created_at < date }.count
    end

    respond_to do |format|
      format.html
      format.csv { render text: User.order('created_at DESC').limit(params[:limit] || 300).offset(params[:offset] || 0).to_csv }
    end
  end

  def activate
    @user = User.find params[:id]
    @user.confirm!
    redirect_to pro_users_path
  end
end
