class Newsletter::Recipient < ActiveRecord::Base
  belongs_to :user_profile
  belongs_to :newsletter

  # The email of the recipient.
  #
  # @return a String.
  def email
    user_profile.email
  end
end
