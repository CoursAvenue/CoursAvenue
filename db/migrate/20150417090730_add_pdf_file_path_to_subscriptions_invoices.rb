class AddPdfFilePathToSubscriptionsInvoices < ActiveRecord::Migration
  def change
    add_column :subscriptions_invoices, :pdf_file_path, :string
  end
end
