class Pro::SubscriptionsPlansController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @monthly_plans = Subscriptions::Plan.monthly
    @yearly_plans  = Subscriptions::Plan.yearly
  end
end
