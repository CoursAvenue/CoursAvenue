class CreateSubscriptionsInvoices < ActiveRecord::Migration
  def change
    create_table :subscriptions_invoices do |t|
      t.string :stripe_invoice_id
      t.datetime :payed_at
      t.references :structure, index: true
      t.references :subscription, index: true

      t.timestamps
    end
  end
end
