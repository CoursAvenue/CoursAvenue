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

    if Rails.env.production?
      User.where(email: 'nim.izadi@gmail.com').first.delay.
        send_sms("Nouveau question publique pour #{@community.structure.name}", '0607653323')
    end
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
    self.delay(run_at: 2.hours.from_now).notify_intercom(@thread)
  end

  # Notify the every participants of an answer by the teacher.
  #
  # @return
  def notify_answer_from_teacher
    memberships = @thread.participants.select(&:can_receive_notifications?)

    memberships.each do |membership|
      CommunityMailer.delay.notify_answer_from_teacher(membership.user, @message, @thread)
    end
  end

  # Notify the every participants and the teacher of an answer by a member.
  #
  # @return
  def notify_answer_from_member
    memberships = @thread.participants.select(&:can_receive_notifications?) - [ @membership ]
    admin = @community.structure.main_contact

    memberships.each do |membership|
      CommunityMailer.delay.notify_answer_from_member(membership.user, @message, @thread)
    end

    CommunityMailer.delay.notify_answer_from_member_to_teacher(admin, @message, @thread)
  end

  private

  def notify_sleeping
    structure = @community.structure
    if structure.is_sleeping? and structure.email.present?
      CommunityMailer.delay.notify_sleeping_of_question(structure, @thread)
    end
  end

  # Notify intercom if there hasn't been an answer to the thread.
  def notify_intercom(thread)
    if thread.messages.count == 1
      IntercomMailer.delay.notify_no_public_reply(thread)
    end
  end
end
