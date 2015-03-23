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
end
