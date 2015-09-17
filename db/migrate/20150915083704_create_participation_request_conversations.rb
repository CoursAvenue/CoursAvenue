class CreateParticipationRequestConversations < ActiveRecord::Migration
  def change
    create_table :participation_request_conversations do |t|
      t.references :participation_request
      t.references :mailboxer_conversation
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :participation_request_conversations, :participation_request_id,
      name: 'index_conversations_on_participation_request_id'
    add_index :participation_request_conversations, :mailboxer_conversation_id,
      name: 'index_conversations_on_mailboxer_conversation_id'
  end
end
