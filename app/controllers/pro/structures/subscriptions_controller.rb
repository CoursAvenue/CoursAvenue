class Pro::Structures::SubscriptionsController < Pro::ProController
  before_action :authenticate_pro_admin!, :set_structure

  layout 'admin'

  def index
    @subscription  = @structure.subscription
    @monthly_plans = Subscriptions::Plan.monthly
    @yearly_plans  = Subscriptions::Plan.yearly
  end

  def create
    aaaaa?
  end

  private

  def set_structure
    @structure = Structure.find(params[:structure_id])
  end
end
