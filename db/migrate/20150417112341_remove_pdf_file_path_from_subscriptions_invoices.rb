class RemovePdfFilePathFromSubscriptionsInvoices < ActiveRecord::Migration
  def change
    remove_column :subscriptions_invoices, :pdf_file_path, :string
  end
end
