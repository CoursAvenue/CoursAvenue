class AddPromotionCodeIdToSubscriptionPlan < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :promotion_code_id, :integer
  end
end
