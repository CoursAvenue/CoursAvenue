class AddIndexToStripeCustomerIdInPaymentCustomer < ActiveRecord::Migration
  def change
    add_index :payment_customers, :stripe_customer_id
  end
end
