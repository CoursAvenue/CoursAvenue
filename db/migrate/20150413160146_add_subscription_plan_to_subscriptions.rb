class AddSubscriptionPlanToSubscriptions < ActiveRecord::Migration
  def change
    add_reference :subscriptions, :subscriptions_plan, index: true
  end
end
