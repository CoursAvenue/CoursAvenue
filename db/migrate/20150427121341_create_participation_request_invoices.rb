class CreateParticipationRequestInvoices < ActiveRecord::Migration
  def change
    create_table :participation_request_invoices do |t|
      t.string   :stripe_invoice_id
      t.datetime :payed_at
      t.integer  :participation_request_id
      t.datetime :deleted_at
      t.boolean  :generated

      t.timestamps
    end
    add_index :participation_request_invoices, :stripe_invoice_id, unique: true
    add_index :participation_request_invoices, :participation_request_id, name: 'index_participation_request_invoices_on_participation_request'
  end
end
