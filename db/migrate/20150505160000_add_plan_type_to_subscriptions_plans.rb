class AddPlanTypeToSubscriptionsPlans < ActiveRecord::Migration
  def change
    add_column :subscriptions_plans, :plan_type, :string
  end
end
