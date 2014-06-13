# encoding: utf-8
class Pro::Structures::OrdersController <  Pro::ProController
  before_action :authenticate_pro_admin!
  layout 'admin'

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @orders    = @structure.orders
  end
end
