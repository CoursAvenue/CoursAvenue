class RenameMailboxerConversationSubjectDemandeDinfos < ActiveRecord::Migration
  def change
    Mailboxer::Conversation.where(subject: "Demande d'informations").update_all(subject: "Demande d'information")
  end
end
