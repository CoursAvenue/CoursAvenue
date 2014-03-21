# encoding: utf-8
class Pro::UsersController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  authorize_resource :users

  def index
    if params[:with_comments]
      @users = User.active.joins { comments }.where { comments.user_id == users.id }.order('created_at DESC').limit(100)
    else
      @users = User.active.order('created_at DESC').limit(100)
    end
    @users_per_hour = { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0, 13 => 0, 14 => 0, 15 => 0, 16 => 0, 17 => 0, 18 => 0, 19 => 0, 20 => 0, 21 => 0, 22 => 0, 23 => 0 }
    User.active.find_each do |user|
      @users_per_hour[user.created_at.hour] += 1
    end

    @users_graph = User.where{created_at > 2.months.ago}.active.count(order: "DATE(created_at) ASC", group: ["DATE(created_at)"])
    respond_to do |format|
      format.html
      format.csv { render text: User.order('created_at DESC').limit(params[:limit] || 300).offset(params[:offset] || 0).to_csv }
    end
  end
end
