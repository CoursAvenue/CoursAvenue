class RemoveDefaultAmountFromSubscriptionsPlans < ActiveRecord::Migration
  def up
    change_column_default :subscriptions_plans, :amount, nil
  end

  def down
    change_column_default :subscriptions_plans, :amount, 0
  end
end
