# encoding: utf-8
class Pro::UsersController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  authorize_resource :users

  def index
    @users         = User.order('created_at DESC').limit(300)
  end

end
