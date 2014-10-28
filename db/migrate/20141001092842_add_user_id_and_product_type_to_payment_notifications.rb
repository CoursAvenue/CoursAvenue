class AddUserIdAndProductTypeToPaymentNotifications < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :user_id, :integer
    add_column :payment_notifications, :product_type, :string

    PaymentNotification.update_all product_type: 'premium_account'
  end
end
