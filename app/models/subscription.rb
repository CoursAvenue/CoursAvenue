class Subscription < ActiveRecord::Base
  include Concerns::HstoreHelper

  acts_as_paranoid

  ######################################################################
  # Constants                                                          #
  ######################################################################

  CURRENCY        = 'EUR'

  # TODO: Add a setting in the backend.
  APPLICATION_FEE = 0 # The application fee in cents.

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessor :stripe_token, :promo_code, :stripe_bank_token, :bank_account_number
  attr_accessible :structure, :coupon, :plan, :stripe_subscription_id, :trial_ends_at, :charged_at,
    :cancelation_reason_dont_want_more_students,
    :cancelation_reason_stopping_activity,
    :cancelation_reason_didnt_have_return_on_investment,
    :cancelation_reason_too_hard_to_use,
    :cancelation_reason_other

  belongs_to :structure
  belongs_to :plan,         class_name: 'Subscriptions::Plan',   foreign_key: 'subscriptions_plan_id'
  belongs_to :coupon,       class_name: 'Subscriptions::Coupon', foreign_key: 'subscriptions_coupon_id'
  has_many   :invoices,     class_name: 'Subscriptions::Invoice'
  has_many   :sponsorships, class_name: 'Subscriptions::Sponsorship'

  store_accessor :metadata,
    :cancelation_reason_dont_want_more_students,
    :cancelation_reason_dont_want_more_students,
    :cancelation_reason_stopping_activity,
    :cancelation_reason_didnt_have_return_on_investment,
    :cancelation_reason_too_hard_to_use,
    :cancelation_reason_other,
    :cancelation_reason_text

  define_boolean_accessor_for :metadata, :cancelation_reason_dont_want_more_students,
    :cancelation_reason_stopping_activity,
    :cancelation_reason_didnt_have_return_on_investment,
    :cancelation_reason_too_hard_to_use

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :stripe_subscription_id, uniqueness: true, allow_blank: true

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  scope :running,  -> { where(canceled_at: nil) }
  scope :canceled, -> { where.not(canceled_at: nil) }
  scope :paused,   -> { where(paused: true) }

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # TODO: Memoize object.
  # Retrieve the Stripe::Subscription. Useful for changing plans.
  #
  # @return nil or a Stripe::Subscription.
  def stripe_subscription
    if stripe_subscription_id.nil? or structure.nil? or structure.stripe_customer.nil?
      return nil
    end

    # TODO: Remove explicit api key.
    structure.stripe_customer.subscriptions.retrieve(stripe_subscription_id, { api_key: Stripe.api_key })
  end

  # Wether the subscription is canceled or not.
  #
  # @return a Boolean.
  def canceled?
    self.canceled_at.present?
  end

  # Wether the subscription is active or not.
  #
  # @return a Boolean.
  def active?
    (in_trial? or (!canceled? and stripe_subscription_id.present?))
  end

  # Wether the subscription is active and not in trial
  #
  # @return a Boolean.
  def active_and_paying?
    (!canceled? and stripe_subscription_id.present?)
  end

  # Charge the subscription. Usually after the trial period.
  #
  # @param token The Stripe token for when we create a new user.
  #
  # @return nil or error_code_value: nil = success
  def charge!(token = nil, coupon = nil)
    error_code_value = nil
    begin
      customer = structure.stripe_customer || structure.create_stripe_customer(token)
      return nil if customer.nil?

      options = {
        plan:      self.plan.stripe_plan_id,
        trial_end: trial_ends_at.to_i
      }

      if coupon.present? and coupon.valid?
        options.merge!({ coupon: coupon.stripe_coupon_id })
        self.coupon = coupon
      end

      _subscription = customer.subscriptions.create(options, { api_key: Stripe.api_key })

      self.stripe_subscription_id = _subscription.id
      self.charged_at             = DateTime.now
      save

      if self.structure.sponsorship_token.present?
        sponsorship = Subscriptions::Sponsorship.where(token: self.structure.sponsorship_token).first
        sponsorship.redeem!(self) unless sponsorship.nil?
      end

    rescue Stripe::CardError => exception
      Bugsnag.notify(exception)
      error_code_value = 'fail'
    end
    error_code_value
  end

  # Cancel the subscription
  #
  # @param at_period_end Flag to delay the cancellation of the subscription until the end of the
  # current period. By default is true.
  #
  # @return
  def cancel!(options = { at_period_end: true })
    if stripe_subscription_id.nil? or structure.nil? or structure.stripe_customer.nil? or canceled?
      return false
    end

    # TODO: Remove explicit api key.
    subscription = structure.stripe_customer.subscriptions.retrieve(stripe_subscription_id, { api_key: Stripe.api_key }).delete(at_period_end: options[:at_period_end])

    self.canceled_at = Time.current

    if options[:at_period_end]
      self.expires_at = Time.at(subscription.current_period_end)
    else
      self.expires_at = self.canceled_at
    end

    self.save

    subscription
  end

  # Pause the subscription
  #
  # @return
  def pause!
    self.paused = true
    save
  end

  # Resume the subscription
  #
  # @return
  def resume!
    self.paused = false
    save
  end

  # Reactivates current plan.
  #
  # @return Boolean (saved or not)
  def reactivate!
    change_plan!(plan)
    self.canceled_at = nil
    save
  end

  # Changes the plan.
  #
  # @return Boolean (saved or not)
  def change_plan!(plan)
    subscription      = stripe_subscription
    subscription.plan = plan.stripe_plan_id
    subscription.save

    self.plan = plan
    save
  end

  # Return the end of the current period as a date. (AKA the next billing date)
  #
  # @return a date or nil.
  def current_period_end
    return nil if stripe_subscription_id.nil? or canceled?

    @current_period_end ||= Time.at(stripe_subscription.current_period_end)
    @current_period_end
  end

  # Return the next amount to be payed.
  #
  # @return Integer or nil
  def next_amount
    return nil if stripe_subscription_id.nil? or canceled?

    expiration_delay = current_period_end - Time.now
    Rails.cache.fetch ["Subscription#next_amount", self], expires_in: expiration_delay.to_i do
      Stripe::Invoice.upcoming(customer: structure.stripe_customer_id).amount_due / 100.0
    end
  end

  # Return the next amount to be payed.
  #
  # @return Integer or nil
  def coupon_end_date
    return nil if !coupon
    return coupon_ends_at if coupon_ends_at.present?
    if (discount = Stripe::Invoice.upcoming(customer: structure.stripe_customer_id).discount)
      coupon_ends_at = Time.at(discount.end || discount.start)
      save
    end
    coupon_ends_at
  end

  # Apply a coupon to the next invoice.
  #
  # @return the new amount or nil
  def apply_coupon(coupon)
    return nil if stripe_subscription_id.nil? or canceled? or coupon.nil? or !coupon.valid?

    # Update current customer with coupon
    stripe_customer        = structure.stripe_customer
    stripe_customer.coupon = coupon.stripe_coupon_id
    stripe_customer.save

    self.coupon = coupon
    save
  end

  # Whether coupon is currently applied on the Subscription
  #
  # @return a Boolean
  def has_coupon?
    coupon.present?
  end

  # Whether the Subscription is still in its trial method.
  #
  # @return a boolean
  def in_trial?
    return false if trial_ends_at.nil?

    trial_ends_at > DateTime.current
  end
end
