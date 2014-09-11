class RenameBe2billNotificationsToPaymentNotifications < ActiveRecord::Migration
  def change
    rename_table :be2bill_notifications, :payment_notifications
    add_column :payment_notifications, :type, :string
    PaymentNotification.update_all type: 'PaymentNotification::Be2bill'
  end
end
