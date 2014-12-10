class AddPaypalProfileIdToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :paypal_recurring_profile_token, :string
  end
end
