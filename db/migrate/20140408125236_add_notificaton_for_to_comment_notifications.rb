class AddNotificatonForToCommentNotifications < ActiveRecord::Migration
  def change
    add_column :comment_notifications, :notification_for, :string
  end
end
