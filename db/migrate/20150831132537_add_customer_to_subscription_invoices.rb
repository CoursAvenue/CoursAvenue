class AddCustomerToSubscriptionInvoices < ActiveRecord::Migration
  def up
    add_reference :subscriptions_invoices, :structure_customer, index: true

    Subscriptions::Invoice.find_each do |invoice|
      structure = invoice.structure
      if structure.present?
        customer = structure.customer ||
          structure.create_customer(stripe_customer_id: structure.stripe_customer_id)
        invoice.customer = customer
        invoice.save
      end
    end
  end

  def down
    remove_reference :subscriptions_invoices, :structure_customer, index: true
  end
end
