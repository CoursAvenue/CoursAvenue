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
  # @param sender  The message sender. By default the user but can be the structure if the pr is
  # rebooked.
  #
  # @return Wether the message was sent or not.
  def send_request!(message, sender = user)
    return false if message.nil?

    recipient = (sender == user ? structure.main_contact : user)

    receipt = sender.send_message_with_label(recipient, message,
      I18n.t(Mailboxer::Label::REQUEST.name), Mailboxer::Label::REQUEST.id)
    self.mailboxer_conversation = receipt.conversation
    receipt.conversation.update_column(:participation_request_id, participation_request.id)
    save

    ParticipationRequest::Notifier.new(participation_request).notify_request_creation

    true
  end

  # Reply to the conversation.
  #
  # @param message the message
  # @param replier
  #
  # @return Wether the message was sent or not.
  def reply!(message_body, replied_by = 'Structure')
    return false if message_body.nil? or replied_by.nil?

    replier = (replied_by == 'Structure' ? structure.main_contact : user)
    self.mailboxer_conversation.update_column(:lock_email_notification_once, true)
    receipt = replier.reply_to_conversation(mailboxer_conversation, message_body)

    receipt.message
  end
end
