class ReplyToken < ActiveRecord::Base
  extend FriendlyId
  ######################################################################
  # Macros                                                             #
  ######################################################################
  friendly_id :token, use: [:finders]
  store_accessor :data, :sender_id, :sender_type,
                        :conversation_id, :participation_request_id

  attr_accessible :token, :reply_type, :data
  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :reply_type, presence: true

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_create :create_token

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
