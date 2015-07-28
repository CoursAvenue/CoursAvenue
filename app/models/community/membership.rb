class Community::Membership < ActiveRecord::Base

  attr_accessible :user

  belongs_to :community
  belongs_to :user

  has_many :message_threads, class_name: 'Community::MessageThread',
    foreign_key: 'community_membership_id'
end
