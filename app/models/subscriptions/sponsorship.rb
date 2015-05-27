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

    # Coupon created for sponsorer
    sponsor_coupon   = Subscriptions::Coupon.create(
      amount:          subscription.plan.monthly_amount,
      name:            "1 mois offert - parrainage de #{ sponsored_structure_name }",
      duration:        'once',
      max_redemptions: 1
    )

    subscription.apply_coupon(sponsor_coupon)

    # Coupon created for sponsored user
    sponsored_coupon = Subscriptions::Coupon.create(
      amount:          amount_for_sponsored,
      name:            name_for_sponsored,
      duration:        'once',
      max_redemptions: 1
    )

    sponsored_subscription.apply_coupon(sponsored_coupon)

    self.redeemed            = true
    self.redeeming_structure = sponsored_subscription.structure
    save
    SubscriptionsSponsorshipMailer.delay.subscription_reedeemed(self)
  end

  # Send an email to the sponsored structure.
  #
  # @return
  def notify_sponsored(custom_message = nil)
    SubscriptionsSponsorshipMailer.delay.sponsor_user(self, custom_message)
  end

  # Amount for the sponsored structure
  # @return Double amount of the promo code
  def amount_for_sponsored
    subscription.plan.monthly_amount / 2.0
  end

  # Description of the coupon shown to the sponsored structure
  # @return String
  def name_for_sponsored
    "1 mois offert - parrainage de #{ subscription.structure.name }"
  end

  private

  # Create a uniq random token.
  # We generate a UUID like: `2d931510-d99f-494a-8c67-87feb05e1594` and then split it to make it
  # friendlier than generating a purely random string.
  #
  # @return
  def create_token
    if self.token.nil?
      self.token = loop do
        random_token = "PARRAIN-#{SecureRandom.uuid.split('-').first}"
        break random_token unless self.class.exists?(token: random_token)
      end
    end
  end
end
