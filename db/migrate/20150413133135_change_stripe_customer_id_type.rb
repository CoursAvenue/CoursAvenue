class ChangeStripeCustomerIdType < ActiveRecord::Migration
  def change
    change_column :structures, :stripe_customer_id, :string
  end
end
