class CreateSubscriptionsPlans < ActiveRecord::Migration
  def change
    create_table :subscriptions_plans do |t|
      t.string :stripe_plan_id
      t.integer :amount
      t.string :interval
      t.string :name

      t.timestamps
    end
    add_index :subscriptions_plans, :stripe_plan_id, unique: true
  end
end
