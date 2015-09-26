class AddDeletedAtToPaymentCustomers < ActiveRecord::Migration
  def change
    add_column :payment_customers, :deleted_at, :datetime
  end
end
