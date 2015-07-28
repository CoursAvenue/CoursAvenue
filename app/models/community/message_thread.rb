class Community::MessageThread < ActiveRecord::Base
  belongs_to :community
  belongs_to :membership, class_name: 'Community::Membership', foreign_key: 'community_membership_id'
  belongs_to :conversation, class_name: 'Mailboxer::Conversation',
    foreign_key: 'mailboxer_conversation_id'
end
