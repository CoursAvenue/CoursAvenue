class Subscriptions::Coupon < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Constants                                                          #
  ######################################################################

  CURRENCY  = 'EUR'

  DURATIONS = {
    once:      'Une fois',
    forever:   'Pour toujours',
    repeating: 'Se repete'
  }

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :name, :amount, :duration, :max_redemptions, :duration_in_months,
                  :stripe_coupon_id, :redeem_by

  has_many :subscriptions, foreign_key: 'subscriptions_coupon_id'

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :name,     presence: true
  validates :amount,   presence: true
  validates :duration, presence: true, inclusion: { in: DURATIONS.keys.map(&:to_s) }

  ######################################################################
  # Callbacks                                                          #
  ######################################################################

  after_create :create_stripe_coupon

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Retrieve the Stripe::Coupon.
  #
  # @return nil or a Stripe::Coupon
  def stripe_coupon
    return nil if stripe_coupon_id.nil?

    Stripe::Coupon.retrieve(stripe_coupon_id, { api_key: Stripe.api_key })
  end

  # Check if the coupon is still valid.
  #
  # @return Boolean
  def still_valid?
    return false if stripe_coupon_id.nil?

    stripe_coupon.valid
  end

  # Delete the coupon from Stripe
  #
  # @return a Boolean
  def delete_stripe_coupon!
    coupon = stripe_coupon
    return nil if coupon.nil?

    coupon.delete
    self.stripe_coupon_id = nil

    save
  end

  # Simple getter for the stripe coupon id
  #
  # @return a String or nil
  def code
    stripe_coupon_id
  end

  private

  def create_stripe_coupon
    options = {
      duration:           duration,
      duration_in_months: duration_in_months,
      currency:           CURRENCY,
      amount_off:         (amount * 100).to_i,
      redeem_by:          redeem_by,
      metadata: {
        name: name
      }
    }

    options[:max_redemptions] = 1 if max_redemptions.present?
    options[:id]              = stripe_coupon_id if stripe_coupon_id.present?

    stripe_coupon = Stripe::Coupon.create(options)
    self.stripe_coupon_id = stripe_coupon.id

    save
  end
end
