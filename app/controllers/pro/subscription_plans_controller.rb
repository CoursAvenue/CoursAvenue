# encoding: utf-8
class Pro::SubscriptionPlansController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @subscription_plans = SubscriptionPlan.all
  end
end
