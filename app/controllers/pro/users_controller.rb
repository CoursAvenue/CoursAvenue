# encoding: utf-8
class Pro::UsersController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  authorize_resource :users

  def index
    if params[:with_comments]
      @users = User.active.joins{comments}.where{comments.user_id == users.id}.order('created_at DESC').limit(100)
    else
      @users = User.order('created_at DESC').limit(300)
    end
  end

end
