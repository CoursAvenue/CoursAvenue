class RemoveAmountFromSubscriptionsPlans < ActiveRecord::Migration
  def change
    remove_column :subscriptions_plans, :amount
  end
end
