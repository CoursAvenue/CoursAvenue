class JoinAmountFieldsInSubscriptionsPlans < ActiveRecord::Migration
  def up
    add_column :subscriptions_plans, :amount, :integer, default: 0

    remove_column :subscriptions_plans, :amount_cents
    remove_column :subscriptions_plans, :amount_unit
  end

  def down
    add_column :subscriptions_plans, :amount_unit, :integer, default: 0
    add_column :subscriptions_plans, :amount_cents, :integer, default: 0

    remove_column :subscriptions_plans, :amount
  end
end
