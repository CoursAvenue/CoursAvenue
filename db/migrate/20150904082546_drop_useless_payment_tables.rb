class DropUselessPaymentTables < ActiveRecord::Migration
  def change
    drop_table :payment_notifications
    drop_table :subscription_plan_exports
    drop_table :subscription_plans
  end
end
