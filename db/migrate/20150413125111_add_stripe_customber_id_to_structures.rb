class AddStripeCustomberIdToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :stripe_customer_id, :integer
    add_index :structures, :stripe_customer_id, unique: true
  end
end
