class Admin::SubscriptionsController < Admin::AdminController

  def index
    @subscriptions = Subscription.all.decorate
  end
end
