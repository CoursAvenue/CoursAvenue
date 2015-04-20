class Subscription < ActiveRecord::Base
  include Concerns::HstoreHelper

  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :structure, :stripe_subscription_id

  belongs_to :structure
  belongs_to :plan,     class_name: 'Subscriptions::Plan', foreign_key: 'subscriptions_plan_id'
  has_many   :invoices, class_name: 'Subscriptions::Invoice'

  store_accessor :metadata, :cancelation_reason_dont_want_more_students,
    :cancelation_reason_dont_want_more_students,
    :cancelation_reason_stopping_activity,
    :cancelation_reason_didnt_have_return_on_investment,
    :cancelation_reason_too_hard_to_use,
    :cancelation_reason_not_satisfied_of_coursavenue_users,
    :cancelation_reason_other,
    :cancelation_reason_text

  define_boolean_accessor_for :metadata, :cancelation_reason_dont_want_more_students,
    :cancelation_reason_dont_want_more_students,
    :cancelation_reason_stopping_activity,
    :cancelation_reason_didnt_have_return_on_investment,
    :cancelation_reason_too_hard_to_use,
    :cancelation_reason_not_satisfied_of_coursavenue_users,
    :cancelation_reason_other

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :stripe_subscription_id, uniqueness: true

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  scope :running,  -> { where(canceled_at: nil) }
  scope :canceled, -> { where.not(canceled_at: nil) }

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
    ! canceled?
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

  # Changes the plan.
  #
  # @return the new plan.
  def change_plan!(plan)
    return if self.plan == plan

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

    Time.at(stripe_subscription.current_period_end)
  end

  # Return the next amount to be payed.
  #
  # @return Integer or nil
  def next_amount
    return nil if stripe_subscription_id.nil? or canceled?
  end

  # Apply a coupon to the next invoice.
  #
  # @return the new amount or nil
  def apply_coupon(coupon)
    return nil if stripe_subscription_id.nil? or canceled? or !coupon.valid?
  end

  # Whether coupon is currently applied on the Subscription
  #
  # @return a Boolean
  def has_coupon?
    false
  end
end
