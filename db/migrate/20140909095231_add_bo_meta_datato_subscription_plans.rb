class AddBoMetaDatatoSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :bo_meta_data, :hstore
  end
end
