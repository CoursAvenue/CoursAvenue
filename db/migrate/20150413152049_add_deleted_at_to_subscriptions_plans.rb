class AddDeletedAtToSubscriptionsPlans < ActiveRecord::Migration
  def change
    add_column :subscriptions_plans, :deleted_at, :timestamp
  end
end
