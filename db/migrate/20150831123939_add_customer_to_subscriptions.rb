class AddCustomerToSubscriptions < ActiveRecord::Migration
  def up
    add_reference :subscriptions, :structure_customer, index: true

    Subscription.find_each do |subscription|
      structure = subscription.structure
      if structure.present?
        customer = structure.customer ||
          structure.create_customer(stripe_customer_id: structure.stripe_customer_id)
        subscription.customer = customer
        subscription.save
      end
    end
  end

  def down
    remove_reference :subscriptions, :structure_customer, index: true
  end
end
