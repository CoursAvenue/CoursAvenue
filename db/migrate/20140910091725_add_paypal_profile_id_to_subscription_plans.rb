class AddPaypalProfileIdToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :paypal_profile_id, :string
  end
end
