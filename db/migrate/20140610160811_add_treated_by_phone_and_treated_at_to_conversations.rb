class AddTreatedByPhoneAndTreatedAtToConversations < ActiveRecord::Migration
  def change
    add_column :mailboxer_conversations, :treated_by_phone, :boolean, default: false
    add_column :mailboxer_conversations, :treated_at, :datetime
  end
end
