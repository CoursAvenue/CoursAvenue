class Subscription < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :structure, :stripe_subscription_id

  belongs_to :structure
  belongs_to :plan, class_name: 'Subscriptions::Plan', foreign_key: 'subscriptions_plan_id'

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

  # TODO: Remove explicit api key.
  # TODO: Memoize object.
  # Retrieve the Stripe::Subscription. Useful for changing plans.
  #
  # @return nil or a Stripe::Subscription.
  def stripe_subscription
    if stripe_subscription_id.nil? or structure.nil? or structure.stripe_customer.nil?
      return nil
    end

    structure.stripe_customer.subscriptions.retrieve(stripe_subscription_id, { api_key: Stripe.api_key })
  end

  # Wether the subscription is canceled or not.
  #
  # @return a Boolean.
  def canceled?
    self.canceled_at.present?
  end

  # TODO: Remove explicit api key.
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

    subscription = structure.stripe_customer.subscriptions.retrieve(stripe_subscription_id, { api_key: Stripe.api_key }).delete(at_period_end: options[:at_period_end])

    self.canceled_at = Time.current
    self.save

    subscription
  end

  # Change the plan.
  #
  # @return the new plan.
  def change_plan!(plan)
    stripe_subscription.plan = plan.stripe_plan_id
    stripe_subscription.save

    self.plan = plan
    save
  end
end
