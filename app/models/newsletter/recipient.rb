class Newsletter::Recipient < ActiveRecord::Base
  belongs_to :user_profile
  belongs_to :newsletter

  attr_accessible :user_profile, :newsletter

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
end
