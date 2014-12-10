class AddLockEmailNotificationOnceOnMailboxerConversations < ActiveRecord::Migration
  def change
    add_column :mailboxer_conversations, :lock_email_notification_once, :boolean, default: false
  end
end
