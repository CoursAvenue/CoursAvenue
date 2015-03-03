class ReplyToken < ActiveRecord::Base
  extend FriendlyId

  ######################################################################
  # Constants                                                          #
  ######################################################################

  REPLY_TYPES = %w(participation_request conversation)
  GOOGLE_ACTION_USER_AGENT =
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/1.0 (KHTML, like Gecko; Gmail Actions)'

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
  validates :token,      presence: true, uniqueness: true

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_validation :create_token

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
    return false if participation_request.date < Time.current

    !used
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
    end
  end

end
