class ReplyToken < ActiveRecord::Base
  extend FriendlyId

  ######################################################################
  # Constants                                                          #
  ######################################################################

  REPLY_TYPES = %w(participation_request conversation)

  ######################################################################
  # Macros                                                             #
  ######################################################################
  friendly_id :token, use: [:finders]
  store_accessor :data, :sender_id, :sender_type,
                        :conversation_id, :participation_request_id,
                        :gmail_action_name

  attr_accessible :token, :reply_type, :data
  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :reply_type, presence: true

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_create :create_token

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Public: Check if the ReplyToken is still valid.
  # Only applies for Participation Requests.
  #
  # A ReplyToken is still valid if:
  # * The Participation Request conversation is still active.
  # * The Participation Request is still in the future.
  # * It hasn't been used yet.
  #
  # @return a boolean.
  def still_valid?
    return false if self.reply_type == 'conversation'
    participation_request = ParticipationRequest.find self.participation_request_id

    return false if participation_request.state != 'pending'
    return false if participation_request.start_time < Time.current

    self.used
  end

  # Public: Sets the ReplyToken as used.
  #
  # @return self.
  def use!
    self.used = true
    self.save
  end

  private

  # Creates an unique token.
  #
  # @return self
  def create_token
    if self.token.nil?
      self.token = loop do
        random_token = SecureRandom.urlsafe_base64
        break random_token unless ReplyToken.exists?(token: random_token)
      end
      self.save
    end
    nil
  end

end
