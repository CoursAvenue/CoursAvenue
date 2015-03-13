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
end
