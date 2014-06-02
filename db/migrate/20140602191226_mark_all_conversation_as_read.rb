class MarkAllConversationAsRead < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Admin.count
    Admin.find_each do |admin|
      bar.increment!
      admin.mailbox.conversations.map do |conversation|
        conversation.mark_as_read admin
      end
    end
  end
end
