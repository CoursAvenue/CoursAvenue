class AddCommentToCallReminders < ActiveRecord::Migration
  def change
    add_column :call_reminders, :comment, :text
  end
end
