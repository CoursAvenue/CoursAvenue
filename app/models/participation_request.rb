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
    self.state           = 'pending'
    self.last_modified_by = 'User'
    nil
  end

end
