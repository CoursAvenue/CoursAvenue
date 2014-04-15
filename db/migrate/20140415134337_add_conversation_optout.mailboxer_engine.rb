# This migration comes from mailboxer_engine (originally 20131206080416)
class AddConversationOptout < ActiveRecord::Migration
  def self.up
    rename_table :conversations, :mailboxer_conversations
    rename_table :notifications, :mailboxer_notifications
    rename_table :receipts     , :mailboxer_receipts

    create_table :mailboxer_conversation_opt_outs do |t|
      t.references :unsubscriber, :polymorphic => true
      t.references :conversation
    end
    add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", :name => "mb_opt_outs_on_conversations_id", :column => "conversation_id"
  end

  def self.down
    remove_foreign_key "mailboxer_conversation_opt_outs", :name => "mb_opt_outs_on_conversations_id"
    drop_table :mailboxer_conversation_opt_outs
    rename_table :mailboxer_conversations, :conversations
    rename_table :mailboxer_notifications, :notifications
    rename_table :mailboxer_receipts     , :receipts
  end
end
