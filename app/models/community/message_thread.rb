# By default, a message thread is not approved. (See schema).
class Community::MessageThread < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :community

  belongs_to :community
  belongs_to :indexable_card
  belongs_to :membership, class_name: 'Community::Membership',
    foreign_key: 'community_membership_id'
  belongs_to :conversation, class_name: 'Mailboxer::Conversation',
    foreign_key: 'mailboxer_conversation_id'

  delegate :messages, to: :conversation, allow_nil: true

  scope :approved, -> { where(approved: true) }

  # Send a message to the teacher and the community.
  #
  # @return
  def send_message!(message)
    message = StringHelper.replace_email_and_phones(message)
    user = membership.user
    admin = community.structure.admin

    receipt = user.send_message_with_label(admin, message,
      I18n.t(Mailboxer::Label::PUBLIC_QUESTION.name), Mailboxer::Label::PUBLIC_QUESTION.id)
    self.conversation = receipt.conversation

    save
  end

  # Approve and notify members.
  #
  # @return
  def approve!
    return if self.approved?

    self.approved = true
    save

    Community::Notifier.new(self, message, membership).notify_admin
    Community::Notifier.new(self, messages.last.body, nil).notify_members
  end

  # Reply to the conversation.
  #
  # @return self
  def reply!(replier, message)
    message = StringHelper.replace_email_and_phones(message)
    conversation.update_column :lock_email_notification_once, true
    receipt = replier.reply_to_conversation(conversation, message)

    if replier.is_a?(Admin)
      Community::Notifier.new(self, message, nil).notify_answer_from_teacher
    elsif self.approved?
      # Only notfiy the community of an answer if the thread is approved.
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
