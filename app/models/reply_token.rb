class ReplyToken < ActiveRecord::Base
  include Concerns::HasRandomToken

  ######################################################################
  # Constants                                                          #
  ######################################################################

  REPLY_TYPES = %w(participation_request conversation comment community)

  ######################################################################
  # Macros                                                             #
  ######################################################################
  store_accessor :data, :sender_id, :sender_type,
                        :conversation_id, :participation_request_id,
                        :gmail_action_name, :thread_id

  attr_accessible :token, :reply_type, :data
  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :reply_type, presence: true
  validates :token,      presence: true, uniqueness: true


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

    return false if !participation_request.state.pending?
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

  # The email address associated with this ReplyToken
  #
  # @return string
  def email_address
    "CoursAvenue <#{token}@#{CoursAvenue::Application::MANDRILL_REPLY_TO_DOMAIN}>"
  end

end
