class AddPublicNameToSubscriptionsPlans < ActiveRecord::Migration
  def change
    add_column :subscriptions_plans, :public_name, :string
  end
end
