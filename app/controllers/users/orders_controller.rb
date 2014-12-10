# encoding: utf-8
class Users::OrdersController <  Pro::ProController

  before_action :authenticate_user!
  load_and_authorize_resource :user, find_by: :slug

  layout 'user_profile'

  def index
    @orders = @user.orders
  end

  def show
    @order = @user.orders.find params[:id]
  end

  protected

  def layout_locals
    { hide_menu: true }
  end

end
