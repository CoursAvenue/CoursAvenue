class Newsletter::Recipient < ActiveRecord::Base
  belongs_to :user_profile
  def user_profile
    UserProfile.unscope{ super }
  end

  belongs_to :newsletter

  attr_accessible :user_profile, :newsletter, :mandrill_message_id

  # The email of the recipient.
  #
  # @return a String.
  def email
    user_profile.email
  end

  # Convert a recipient to a Mandrill recipient.
  #
  # @param type The header type to use for the recipient
  #
  # @return a mandrill recipient
  def to_mandrill_recipient(type = 'bcc')
    {
      email: self.email,
      name: user_profile.name,
      type: type
    }
  end

  # Create a some recipient metadata to send with a Mandrill email.
  #
  # @return a Hash.
  def mandrill_recipient_metadata
    {
      rcpt:   self.email,
      values: [
        {
          user_profile: user_profile.id,
          newsletter:   newsletter.id
        }
      ]
    }
  end

  # Update the message status using the mandrill id.
  #
  # @return nothing.
  def update_message_status
    client = MandrillFactory.client
    infos  = client.messages.info(self.mandrill_message_id)

    if infos.present? and infos['opens'].present?
      self.opened                  = infos['opens'] > 0
      self.opens                   = infos['opens']
      self.clicks                  = infos['clicks']
      self.mandrill_message_status = infos['state']
    end

    save
  rescue Mandrill::UnknownMessageError
    # Do nothing if the messages information are not set.
  end
end
