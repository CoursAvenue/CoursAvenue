class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.string   :plan_type
      t.string   :credit_card_number
      t.boolean  :recurrent, default: true
      t.datetime :expires_at
      t.datetime :renewed_at
      t.datetime :canceled_at

      t.hstore   :meta_data

      t.references :structure

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
