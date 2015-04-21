class Pro::Structures::InvoicesController < Pro::ProController
  before_action :authenticate_pro_admin!, :set_structure, :set_subscription

  def index
    @invoices = @structure.invoices
  end

  def download
    @invoice = @structure.invoices.find(params[:id])
  end

  private

  def set_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end

  def set_subscription
    @subscription = @structure.subscription
  end
end
