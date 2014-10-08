class ParticipationRequest < ActiveRecord::Base

  # Declined: when the user decline the proposition made by the other user
  # Canceled: when the teacher cancel after having changed hours or accepted
  STATE = %w(accepted pending declined canceled)

  attr_accessible :state, :date, :start_time, :end_time, :mailboxer_conversation_id, :planning_id, :last_modified_by, :course_id

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :conversation, class_name: 'Mailboxer::Conversation', foreign_key: 'mailboxer_conversation_id'
  belongs_to :planning
  belongs_to :course
  belongs_to :user
  belongs_to :structure

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_create :set_default_attributes
  after_create :send_email_to_teacher

  ######################################################################
  # Validation                                                         #
  ######################################################################
  validates :date, presence: true
  validate :request_is_not_duplicate, on: [:create]

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :accepted, -> { where( state: 'accepted') }
  scope :pending,  -> { where( state: 'pending') }
  scope :upcoming, -> { where( arel_table[:date].gt(Date.today)) }

  #
  # Create a ParticipationRequest if everything is correct, and if it is, it also create a conversation
  #
  # @return ParticipationRequest
  def self.create_and_send_message(request_attributes, message_body, user, structure)
    participation_request           = ParticipationRequest.new request_attributes
    participation_request.user      = user
    participation_request.structure = structure
    if participation_request.valid?
      # Create and send conversation
      structure.create_or_update_user_profile_for_user(user, UserProfile::DEFAULT_TAGS[:discovery_pass])
      recipients                         = structure.main_contact
      receipt                            = user.send_message_with_label(recipients, message_body, I18n.t(Mailboxer::Label::DISCOVERYPASSREQUEST.name), Mailboxer::Label::DISCOVERYPASSREQUEST.id)
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

  # @return Boolean is the request declined?
  def canceled?
    self.state == 'canceled'
  end

  # @return Boolean is the request pending?
  def pending?
    self.state == 'pending'
  end

  # Accept request and send a message to user.
  # @param message String
  #
  # @return Boolean
  def accept!(message_body, last_modified_by='Structure')
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
  def cancel!(message_body, last_modified_by='Structure')
    self.last_modified_by = last_modified_by
    self.state = 'canceled'
    message    = reply_to_conversation(message_body, last_modified_by)
    self.save
    if self.last_modified_by == 'Structure'
      ParticipationRequestMailer.delay.request_has_been_canceled_by_teacher_to_user(self, message)
    elsif self.last_modified_by == 'User'
      ParticipationRequestMailer.delay.request_has_been_canceled_by_user_to_teacher(self, message)
    end
  end

  def place
    if self.planning
      self.planning.place
    else
      self.course.place
    end
  end

  def levels
    if self.planning
      self.planning.levels
    else
      self.course.levels
    end
  end

  private

  # Set state to pending by default when creating
  #
  # @return nil
  def set_default_attributes
    self.state            = 'pending'
    self.last_modified_by = 'User'
    self.start_time       = self.planning.start_time if self.planning and self.start_time.nil?
    self.end_time         = self.planning.end_time   if self.planning and self.end_time.nil?
    self.end_time         = self.start_time + 1.hour if self.start_time and self.end_time.nil?
    nil
  end


  # Check if the request is duplicate or not
  #
  # @return Boolean
  def request_is_not_duplicate
    if self.user.participation_requests.accepted.where(ParticipationRequest.arel_table[:created_at].gt(Date.today - 1.week).and(ParticipationRequest.arel_table[:planning_id].eq(self.planning_id))).any?
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

  def reply_to_conversation(message_body, last_modified_by)
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
