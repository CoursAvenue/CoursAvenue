class Community::MessageThread < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :community

  belongs_to :community
  belongs_to :indexable_card
  belongs_to :membership, class_name: 'Community::Membership', foreign_key: 'community_membership_id'
  belongs_to :conversation, class_name: 'Mailboxer::Conversation',
    foreign_key: 'mailboxer_conversation_id'

  delegate :messages, to: :conversation, allow_nil: true

  # Send a mewssage to the teacher and the community.
  #
  # @return
  def send_message!(message)
    User.where(email: 'nim.izadi@gmail.com').first.delay.send_sms("Nouveau message publique pour #{community.structure.name}", '0607653323')
    user = membership.user
    admin = community.structure.main_contact

    receipt = user.send_message_with_label(admin, message,
      I18n.t(Mailboxer::Label::PUBLIC_QUESTION.name), Mailboxer::Label::PUBLIC_QUESTION.id)
    self.conversation = receipt.conversation

    save
  end

  # Reply to the conversation.
  #
  # @return self
  def reply!(replier, message)
    User.where(email: 'nim.izadi@gmail.com').first.delay.send_sms("Nouveau réponse publique pour #{community.structure.name}", '0607653323')
    conversation.update_column :lock_email_notification_once, true
    receipt = replier.reply_to_conversation(conversation, message)

    if replier.is_a?(Admin)
      Community::Notifier.new(self, message, nil).notify_answer_from_teacher
    else
      membership = community.memberships.where(user: replier).first ||
        community.memberships.create(user: replier)
      Community::Notifier.new(self, message, membership).notify_answer_from_member
    end

    self
  end

  # Every person that as a message in the thread.
  #
  # @return an array of Community::Membership.
  def participants
    users = messages.includes(:sender).map(&:sender).uniq.select { |u| u.is_a?(User) }

    users.map do |user|
      community.memberships.where(user: user).first
    end
  end
end
