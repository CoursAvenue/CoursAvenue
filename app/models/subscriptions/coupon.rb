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

  attr_accessible :name, :amount, :duration

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

    Stripe::Coupon.retrieve(stripe_coupon_id)
  end

  # Check if the coupon is still valid.
  #
  # @return Boolean
  def still_valid?
    return false if stripe_coupon_id.nil?

    stripe_coupon.valid
  end

  private

  def create_stripe_coupon
    stripe_coupon = Stripe::Coupon.create(duration: self.duration, currency: CURRENCY)
    self.stripe_coupon_id = stripe_coupon.id

    save
  end

  handle_asynchronously :create_stripe_coupon
end
