# encoding: utf-8
class Pro::Structures::OrdersController <  Pro::ProController
  before_action :authenticate_pro_admin!
  layout 'admin'

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @orders    = @structure.orders
  end

  def show
    @structure = Structure.friendly.find params[:structure_id]
    @order     = @structure.orders.find params[:id]
  end

  def export
    @structure = Structure.friendly.find params[:structure_id]
    @order     = @structure.orders.find params[:id]

    respond_to do |format|
      format.html { redirect_to pro_structure_order_path(@structure, @order) }
      format.pdf  { render pdf: 'export', disposition: 'attachment', layout: 'pdf.html' }
    end
  end
end
