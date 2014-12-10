class AddLastRenewalFailedAtToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :last_renewal_failed_at, :datetime
  end
end
