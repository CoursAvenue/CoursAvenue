class Community::Membership < ActiveRecord::Base
  acts_as_paranoid
  # The period in which we don't send a new notification to the user.
  NOTIFICATION_FREE_PERIOD = 10.days

  attr_accessible :user

  belongs_to :community
  belongs_to :user

  has_many :message_threads, class_name: 'Community::MessageThread',
    foreign_key: 'community_membership_id'
end
