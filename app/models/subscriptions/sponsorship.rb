class Subscriptions::Sponsorship < ActiveRecord::Base
  include Concerns::HasRandomToken

  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  belongs_to :subscription

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :sponsored_email, uniqueness: true, presence: true

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Redeem the sponsorship.
  #
  # @return boolean
  def redeem!
    return if redeemed?

    self.redeemed = true
    save
  end

end
