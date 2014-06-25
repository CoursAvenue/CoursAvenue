class AddFlaggedToConversations < ActiveRecord::Migration
  def change
    add_column :mailboxer_conversations, :flagged, :string
    add_column :mailboxer_conversations, :flagged_at, :datetime
  end
end
