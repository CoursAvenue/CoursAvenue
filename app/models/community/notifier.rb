# Every mail sent from the Community must go through this class.
class Community::Notifier
  # The number of people to notify in one go.
  NOTIFICATION_GROUP_COUNT = 10

  # @param thread     - the thread containing the message.
  # @param message    - the raw message.
  # @param membership - the sender of the message.
  def initialize(thread, message, membership = nil)
    @thread     = thread
    @community  = thread.community
    @message    = message
    @membership = membership
  end

  # Notify members of the community and the teacher that there's a new message.
  #
  # @return
  def notify_question
    memberships = @community.memberships.includes(:user).
      select(&:can_receive_notifications?).take(NOTIFICATION_GROUP_COUNT)
    memberships -= [ @membership ] # We remove the user who sent the message.
    admin = @community.structure.main_contact

    memberships.each do |membership|
      CommunityMailer.delay.notify_member_of_question(membership.user, @message, @thread)
      membership.last_notification_at = Time.current
      membership.save
    end

    CommunityMailer.delay.notify_admin_of_question(admin, @message, @thread)
  end
end
