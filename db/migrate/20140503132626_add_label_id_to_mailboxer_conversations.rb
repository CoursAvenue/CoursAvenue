# encoding: utf-8
class AddLabelIdToMailboxerConversations < ActiveRecord::Migration
  def change
    add_column :mailboxer_conversations, :mailboxer_label_id, :integer

    Mailboxer::Conversation.update_all mailboxer_label_id: Mailboxer::Label::CONVERSATION.id
    Mailboxer::Conversation.where(subject: "Demande d'informations").each do |conversation|
      conversation.update_column :mailboxer_label_id, Mailboxer::Label::INFORMATION.id
    end
    Mailboxer::Conversation.where(subject: "Message personnel suite à ma recommandation").each do |conversation|
      conversation.update_column :mailboxer_label_id, Mailboxer::Label::COMMENT.id
    end
  end
end
