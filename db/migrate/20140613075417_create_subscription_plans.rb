class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.string   :plan_type
      t.string   :credit_card_number
      t.string   :be2bill_alias
      t.string   :client_ip
      t.boolean  :recurrent, default: true
      t.date     :expires_at
      t.date     :renewed_at
      t.datetime :canceled_at

      t.hstore   :meta_data

      t.references :structure

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
