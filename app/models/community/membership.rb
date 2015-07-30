class Community::Membership < ActiveRecord::Base
  acts_as_paranoid
  # The period in which we don't send a new notification to the user.
  NOTIFICATION_FREE_PERIOD = 10.days

  attr_accessible :user

  belongs_to :community
  belongs_to :user

  has_many :message_threads, class_name: 'Community::MessageThread',
    foreign_key: 'community_membership_id'

  # Whether or not the user can receive a notification.
  #
  # @return a boolean
  def can_receive_notifications?
    (last_notification_at.nil? or last_notification_at < NOTIFICATION_FREE_PERIOD.ago) and
      user.community_notification_opt_in?
  end
end
