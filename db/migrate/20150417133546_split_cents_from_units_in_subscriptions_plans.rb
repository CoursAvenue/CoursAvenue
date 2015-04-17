class SplitCentsFromUnitsInSubscriptionsPlans < ActiveRecord::Migration
  def change
    add_column :subscriptions_plans, :amount_unit, :integer, default: 0
    add_column :subscriptions_plans, :amount_cents, :integer, default: 0
  end
end
