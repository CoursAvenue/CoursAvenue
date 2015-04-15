class Pro::SubscriptionsPlansController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @monthly_plans = Subscriptions::Plan.monthly
    @yearly_plans  = Subscriptions::Plan.yearly
  end

  def new
    @plan = Subscriptions::Plan.new

    render layout: false
  end

  def create
    @plan = Subscriptions::Plan.new(permitted_params)
  end

  private

  def permitted_params
  end
end
