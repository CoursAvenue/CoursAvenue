class Pro::SubscriptionsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @subscriptions = Subscription.all.decorate
  end
end
