class AddParticipationRequestIdToMailboxerConversations < ActiveRecord::Migration
  def change
    add_column :mailboxer_conversations, :participation_request_id, :integer
  end
end
