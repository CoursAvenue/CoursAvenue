class Subscription < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

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

  # Retrieve the Stripe::Subscription. Useful for changing plans.
  #
  # @return nil or a Stripe::Subscription.
  def stripe_subscription
    if stripe_subscription_id.nil? or structure.nil? or structure.stripe_customer.nil?
      return nil
    end

    structure.stripe_customer.subscriptions.retrieve(stripe_subscription_id)
  end

  # Wether the subscription is canceled or not.
  #
  # @return a Boolean.
  def canceled?
    self.canceled_at.present?
  end

  # Cancel the subscription
  #
  # @param at_period_end Flag to delay the cancellation of the subscription until the end of the
  # current period. By default is true.
  #
  # @return
  def cancel!(at_period_end: true)
    if stripe_subscription_id.nil? or structure.nil? or structure.stripe_customer.nil? or canceled?
      return false
    end

    structure.stripe_customer.subscriptions.retrieve(stripe_subscription_id).delete
    self.canceled_at = Time.current

    save
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
