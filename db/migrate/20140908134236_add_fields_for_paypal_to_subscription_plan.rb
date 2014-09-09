class AddFieldsForPaypalToSubscriptionPlan < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :paypal_token, :string
    add_column :subscription_plans, :paypal_payer_id, :string
  end
end
