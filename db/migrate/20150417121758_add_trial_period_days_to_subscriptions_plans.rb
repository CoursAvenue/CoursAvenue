class AddTrialPeriodDaysToSubscriptionsPlans < ActiveRecord::Migration
  def change
    add_column :subscriptions_plans, :trial_period_days, :integer
  end
end
