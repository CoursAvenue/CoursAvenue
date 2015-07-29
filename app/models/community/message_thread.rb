class Community::MessageThread < ActiveRecord::Base

  attr_accessible :community

  belongs_to :community
  belongs_to :membership, class_name: 'Community::Membership', foreign_key: 'community_membership_id'
  belongs_to :conversation, class_name: 'Mailboxer::Conversation',
    foreign_key: 'mailboxer_conversation_id'

  # Send a mewssage to the teacher and the community.
  #
  # @return
  def send_message!(message)
    user = membership.user
    admin = community.structure.main_contact

    receipt = user.send_message_with_label(admin, message,
     I18n.t(Mailboxer::Label::PUBLIC_QUESTION.name), Mailboxer::Label::PUBLIC_QUESTION.id)
    self.conversation = receipt.conversation

    save
  end
end
