class DropStripeCustomerIdFromStructure < ActiveRecord::Migration
  def change
    remove_column :structures, :stripe_customer_id
  end
end
