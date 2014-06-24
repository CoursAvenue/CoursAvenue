class AddCardExpiresAtToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :card_validity_date, :date
  end
end
