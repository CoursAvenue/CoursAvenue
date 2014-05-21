module Concerns
  module MessagableWithLabel

    extend ActiveSupport::Concern

    # Adding this to be able to specify a label_name when sending a message.
    def send_message_with_label(recipients, msg_body, subject, label_name='conversation', sanitize_text=true, attachment=nil, message_timestamp = Time.now)
      receipt = self.send_message(recipients, msg_body, subject, sanitize_text, attachment, message_timestamp)

      conversation = receipt.conversation
      if conversation
        conversation.update_column :mailboxer_label_id, Mailboxer::Label.where(name: "mailboxer.label.#{label_name}").first.id
      end
      return receipt
    end
  end
end
