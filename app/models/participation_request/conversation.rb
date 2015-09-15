class ParticipationRequest::Conversation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :participation_request
  belongs_to :mailboxer_conversation, class_name: 'Mailboxer::Conversation'

  delegate :messages,  to: :mailboxer_conversation
  delegate :structure, to: :participation_request
  delegate :user,      to: :participation_request

  # The message starting the conversation.
  #
  # @param message The message sent.
  #
  # @return Wether the message was sent or not.
  def send_request!(message)
    return false if message.nil?

    receipt = user.send_message_with_label(structure.main_contact, message,
      I18n.t(Mailboxer::Label::REQUEST.name), Mailboxer::Label::REQUEST.id)
    self.mailboxer_conversation = receipt.conversation
    receipt.conversation.update_column(:participation_request_id, participation_request.id)
    save
  end

  # Reply to the conversation.
  #
  # @param message the message
  # @param replier
  #
  # @return Wether the message was sent or not.
  def reply!(message, replied_by = 'Structure')
    return false if message.nil? or replied_by.nil?

    replier = (replied_by == 'Structure' ? structure.main_contact : user)
    replier.reply_to_conversation(mailboxer_conversation, message)
  end
end
