class AddPaymentCustomerToSubscriptions < ActiveRecord::Migration
  def change
    add_reference :subscriptions, :payment_customer, index: true
  end
end
