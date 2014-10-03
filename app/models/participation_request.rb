class ParticipationRequest < ActiveRecord::Base

  STATE = %w(accepted pending declined)

  attr_accessible :state, :date, :start_time, :end_time, :mailboxer_conversation_id, :planning_id, :last_modified_by

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :conversation, class_name: 'Mailboxer::Conversation', foreign_key: 'mailboxer_conversation_id'
  belongs_to :planning
  belongs_to :user
  belongs_to :structure

  has_one :course, through: :planning

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_create :set_default_attributes

  ######################################################################
  # Validation                                                         #
  ######################################################################
  validates :date, presence: true
  validate :request_is_not_duplicate

  def request_is_not_duplicate
    self.user.participation_requests.where(ParticipationRequest.arel_table[:created_at].gt(Date.today - 1.week).and(
                                           ParticipationRequest.arel_table[:planning_id].not_eq(self.planning_id))).empty?
  end

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

  # @return Boolean is the request pending?
  def pending?
    self.state == 'pending'
  end

  # Accept request and send a message to user.
  # @param message String
  #
  # @return Boolean
  def accept!(message, last_modified_by='Structure')
    self.last_modified_by = last_modified_by
    self.state = 'accepted'
    self.structure.main_contact.reply_to_conversation(self.conversation, message) if message.present?
    self.save
  end

  # Modify request and inform user about it
  # @param message String
  #
  # @return Boolean
  def modify_date!(message, new_params, last_modified_by='Structure')
    self.last_modified_by = last_modified_by
    self.update_attributes new_params
    self.structure.main_contact.reply_to_conversation(self.conversation, message) if message.present?
    self.state = 'pending'
    self.save
  end

  # [accept! description]
  # @param message [type] [description]
  #
  # @return Boolean
  def decline!(message, last_modified_by='Structure')
    self.last_modified_by = last_modified_by
    self.state = 'declined'
    self.structure.main_contact.reply_to_conversation(self.conversation, message)
    self.save
  end

  private

  # Set state to pending by default when creating
  #
  # @return nil
  def set_default_attributes
    self.state            = 'pending'
    self.last_modified_by = 'User'
    self.start_time       = self.planning.start_time if self.start_time.nil?
    self.end_time         = self.planning.end_time   if self.end_time.nil?
    nil
  end

end
