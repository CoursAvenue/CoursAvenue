class AddTextToCommentNotifications < ActiveRecord::Migration
  def change
    add_column :comment_notifications, :text, :text
  end
end
