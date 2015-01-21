class ParticipationRequest < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  # Declined: when the user decline the proposition made by the other user
  # Canceled: when the teacher cancel after having changed hours or accepted
  STATE = %w(accepted pending declined canceled)

  attr_accessible :state, :date, :start_time, :end_time, :mailboxer_conversation_id,
                  :planning_id, :last_modified_by, :course_id, :user, :structure, :conversation,
                  :cancelation_reason_id, :report_reason_id, :report_reason_text, :reported_at

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :conversation, class_name: 'Mailboxer::Conversation', foreign_key: 'mailboxer_conversation_id', touch: true
  belongs_to :planning
  belongs_to :course
  belongs_to :user
  belongs_to :structure
  belongs_to :cancelation_reason, class_name: 'ParticipationRequest::CancelationReason'
  belongs_to :report_reason     , class_name: 'ParticipationRequest::ReportReason'

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_save   :update_times
  before_create :set_default_attributes
  after_create  :send_email_to_teacher
  after_create  :send_sms_to_teacher

  ######################################################################
  # Validation                                                         #
  ######################################################################
  validates :date, presence: true
  validate :request_is_not_duplicate, on: [:create]

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :accepted,             -> { where( state: 'accepted') }
  scope :pending,              -> { where( state: 'pending') }
  scope :upcoming,             -> { where( arel_table[:date].gteq(Date.today)) }
  scope :past,                 -> { where( arel_table[:date].lt(Date.today)) }
  scope :canceled_or_declined, -> { where( arel_table[:state].eq('canceled').or(arel_table[:state].eq('declined'))) }
  scope :tomorrow,             -> { where( state: 'accepted', date: Date.tomorrow ) }

  # Create a ParticipationRequest if everything is correct, and if it is, it also create a conversation
  #
  # @return ParticipationRequest
  def self.create_and_send_message(request_attributes, message_body, user, structure)
    message_body = StringHelper.replace_contact_infos(message_body)
    participation_request           = ParticipationRequest.new date: request_attributes[:date], start_time: request_attributes[:start_time], planning_id: request_attributes[:planning_id], course_id: request_attributes[:course_id]
    participation_request.user      = user
    participation_request.structure = structure
    if participation_request.valid?
      # Create and send conversation
      structure.create_or_update_user_profile_for_user(user, UserProfile::DEFAULT_TAGS[:discovery_pass])
      recipients                         = structure.main_contact
      receipt                            = user.send_message_with_label(recipients, message_body, I18n.t(Mailboxer::Label::REQUEST.name), Mailboxer::Label::REQUEST.id)
      conversation                       = receipt.conversation
      participation_request.conversation = conversation
      participation_request.save
      conversation.update_column :participation_request_id, participation_request.id
    end
    participation_request
  end

  # @return Boolean is the request accepted?
  def accepted?
    self.state == 'accepted'
  end

  # @return Boolean is the request declined?
  def declined?
    self.state == 'declined'
  end

  # @return Boolean is the request canceled?
  def canceled?
    self.state == 'canceled'
  end

  # @return Boolean is the request pending?
  def pending?
    self.state == 'pending'
  end

  #
  # Tells if the resource type is waiting for an answer
  # @param resource_type='Structure' [type] [description]
  #
  # @return Boolean
  def pending_for?(resource_type='Structure')
    (self.state == 'pending' and self.last_modified_by != resource_type)
  end

  # Accept request and send a message to user.
  # @param message String
  #
  # @return Boolean
  def accept!(message_body, last_modified_by='Structure')
    message_body = StringHelper.replace_contact_infos(message_body)
    self.last_modified_by = last_modified_by
    self.state = 'accepted'
    message = reply_to_conversation(message_body, last_modified_by)
    self.save
    if self.last_modified_by == 'Structure'
      ParticipationRequestMailer.delay.request_has_been_accepted_by_teacher_to_user(self, message)
    elsif self.last_modified_by == 'User'
      ParticipationRequestMailer.delay.request_has_been_accepted_by_user_to_teacher(self, message)
    end
  end

  # Modify request and inform user about it
  # @param message String
  #
  # @return Boolean
  def modify_date!(message_body, new_params, last_modified_by='Structure')
    message_body = StringHelper.replace_contact_infos(message_body)
    self.last_modified_by = last_modified_by
    self.update_attributes new_params
    message = reply_to_conversation(message_body, last_modified_by)
    self.state = 'pending'
    self.save
    if self.last_modified_by == 'Structure'
      ParticipationRequestMailer.delay.request_has_been_modified_by_teacher_to_user(self, message)
    elsif self.last_modified_by == 'User'
      ParticipationRequestMailer.delay.request_has_been_modified_by_user_to_teacher(self, message)
    end
  end

  # Decline proposition made by user
  # @param message [type] [description]
  #
  # @return Boolean
  def decline!(message_body, last_modified_by='Structure')
    message_body = StringHelper.replace_contact_infos(message_body)
    self.last_modified_by = last_modified_by
    self.state = 'declined'
    message = reply_to_conversation(message_body, last_modified_by)
    self.save
    if self.last_modified_by == 'Structure'
      ParticipationRequestMailer.delay.request_has_been_declined_by_teacher_to_user(self, message)
    elsif self.last_modified_by == 'User'
      ParticipationRequestMailer.delay.request_has_been_declined_by_user_to_teacher(self, message)
    end
  end

  # Cancel a proposition
  # @param message [type] [description]
  #
  # @return Boolean
  def cancel!(message_body, cancelation_reason_id, last_modified_by='Structure')
    message_body               = StringHelper.replace_contact_infos(message_body)
    self.cancelation_reason_id = cancelation_reason_id
    self.last_modified_by      = last_modified_by
    self.state                 = 'canceled'
    message    = reply_to_conversation(message_body, last_modified_by)
    self.save
    if self.last_modified_by == 'Structure'
      ParticipationRequestMailer.delay.request_has_been_canceled_by_teacher_to_user(self, message)
    elsif self.last_modified_by == 'User'
      ParticipationRequestMailer.delay.request_has_been_canceled_by_user_to_teacher(self, message)
    end
  end

  def place
    if planning
      planning.place
    elsif course and course.place
      course.place
    else
      structure.places.first
    end
  end

  def levels
    if self.planning
      self.planning.levels
    else
      self.course.levels
    end
  end

  # Tells if the PR is past or not.
  #
  # @return Boolean, wether the date is passed
  def past?
    date < Date.today
  end

  private

  # Set state to pending by default when creating
  #
  # @return nil
  def set_default_attributes
    self.state            ||= 'pending'
    self.last_modified_by ||= 'User'
    self.start_time       ||= self.planning.start_time if self.planning and self.start_time.nil?
    self.end_time         ||= self.planning.end_time   if self.planning
    self.end_time         ||= self.start_time + 1.hour if self.start_time
    self.course           ||= self.planning.course     if self.planning
    nil
  end

  # Update start and end_time if planning changed
  #
  # @return nil
  def update_times
    if self.planning_id_changed?
      self.start_time = self.planning.start_time if self.planning
      self.end_time   = self.planning.end_time   if self.planning
      self.end_time   ||= self.start_time + 1.hour if self.start_time
    end
    nil
  end


  # Check if the request is duplicate or not
  #
  # @return Boolean
  def request_is_not_duplicate
    if self.user.participation_requests.where(ParticipationRequest.arel_table[:created_at].gt(Date.today - 1.week)
                                                 .and(ParticipationRequest.arel_table[:planning_id].eq(self.planning_id))
                                                 .and(ParticipationRequest.arel_table[:date].eq(self.date))).any?
      self.errors[:base] << "duplicate"
      return false
    end
    true
  end

  # When a request is created (always by user), we alert the teacher
  #
  # @return nil
  def send_email_to_teacher
    ParticipationRequestMailer.delay.you_received_a_request(self)
    nil
  end

  # When a request is created (always by user), we alert the teacher via sms
  #
  # @return nil
  def send_sms_to_teacher
    structure.notify_new_participation_request_via_sms(self)
  end

  def reply_to_conversation(message_body, last_modified_by)
    message_body = StringHelper.replace_contact_infos(message_body)
    if message_body.present?
      self.conversation.lock_email_notification_once = true
      self.conversation.save
      if last_modified_by == 'Structure'
        receipt = self.structure.main_contact.reply_to_conversation(self.conversation, message_body)
      else
        receipt = self.user.reply_to_conversation(self.conversation, message_body)
      end
      message = receipt.message
    end
  end

end
