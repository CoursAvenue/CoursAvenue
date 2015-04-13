class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :name
      t.integer :price
      t.string :interval
      t.string :stripe_subscription_id

      t.timestamps
    end
    add_index :subscriptions, :stripe_subscription_id, unique: true
  end
end
