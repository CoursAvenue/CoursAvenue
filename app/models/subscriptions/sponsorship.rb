class Subscriptions::Sponsorship < ActiveRecord::Base
  include Concerns::HasRandomToken

  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :sponsored_email

  belongs_to :subscription
  belongs_to :redeeming_structure, class_name: 'Structure'

  ######################################################################
  # Scope                                                              #
  ######################################################################
  scope :redeemed, -> { where(redeemed: true) }

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :sponsored_email, presence: true, uniqueness: { scope: :subscription_id }

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Redeem the sponsorship.
  #
  # @param sponsored_subscription The subscription of the sponsored structure
  #
  # @return boolean
  def redeem!(sponsored_subscription)
    return if redeemed? or sponsored_subscription.nil?

    structure_name           = subscription.structure.name
    sponsored_structure_name = sponsored_subscription.structure.name

    sponsor_coupon   = Subscriptions::Coupon.create(
      amount:          subscription.plan.monthly_amount,
      name:            "Parrainage structure #{ structure_name } -> #{ sponsored_structure_name }",
      duration:        'once',
      max_redemptions: 1
    )

    subscription.apply_coupon(sponsor_coupon)

    sponsored_coupon = Subscriptions::Coupon.create(
      amount:          sponsored_subscription.plan.monthly_amount / 2.0,
      name:            "Parrainage structure #{ structure_name } <- #{ sponsored_structure_name }",
      duration:        'once',
      max_redemptions: 1
    )

    sponsored_subscription.apply_coupon(sponsored_coupon)

    SubscriptionsSponsorshipMailer.delay.subscription_reedeemed(self)
    self.redeemed            = true
    self.redeeming_structure = sponsored_subscription.structure
    save
  end

  # Send an email to the sponsored structure.
  #
  # @return
  def notify_sponsored(custom_message = nil)
    SubscriptionsSponsorshipMailer.delay.sponsor_user(self, custom_message)
  end
end
