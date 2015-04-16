class AddDeletedAtToSubscriptionsInvoices < ActiveRecord::Migration
  def change
    add_column :subscriptions_invoices, :deleted_at, :datetime
  end
end
