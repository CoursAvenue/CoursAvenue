class AddDefaultToGeneratedInSubscriptionsInvoices < ActiveRecord::Migration
  def up
    change_column_default :subscriptions_invoices, :generated, false
  end

  def down
    change_column_default :subscriptions_invoices, :generated, nil
  end
end
