# encoding: utf-8
class Pro::UsersController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  authorize_resource :users

  def index
    if params[:with_comments]
      @users = User.active.joins { comments }.where { comments.user_id == users.id }.order('created_at DESC').limit(100)
    else
      @users = User.active.order('created_at DESC').limit(300)
    end
    @users_graph = User.where{created_at > 2.months.ago}.active.count(order: "DATE(created_at) ASC", group: ["DATE(created_at)"])
  end
end
