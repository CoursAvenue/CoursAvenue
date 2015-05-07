class Subscriptions::Sponsorship < ActiveRecord::Base
  include Concerns::HasRandomToken

  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :sponsored_email

  belongs_to :subscription

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :sponsored_email, presence: true, uniqueness: { scope: :subscription_id }

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

  # Send an email to the sponsored structure.
  #
  # @return
  def notify_sponsored(custom_message = nil)
    SubscriptionsSponsorshipMailer.delay.sponsor_user(self, custom_message)
  end
end
