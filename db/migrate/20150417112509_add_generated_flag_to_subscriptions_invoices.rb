class AddGeneratedFlagToSubscriptionsInvoices < ActiveRecord::Migration
  def change
    add_column :subscriptions_invoices, :generated, :boolean
  end
end
