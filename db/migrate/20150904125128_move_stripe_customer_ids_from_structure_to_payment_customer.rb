class MoveStripeCustomerIdsFromStructureToPaymentCustomer < ActiveRecord::Migration
  def change
    Structure.where.not(stripe_customer_id: nil).each do |structure|
      if (customer = structure.payment_customer).present?
        customer.stripe_customer_id = structure.stripe_customer_id
        customer.save
      else
        customer = structure.create_payment_customer(
          stripe_customer_id: structure.stripe_customer_id
        )
      end
    end
  end
end
