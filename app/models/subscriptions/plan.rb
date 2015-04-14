class Subscriptions::Plan < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  has_many :subscriptions, foreign_key: 'subscriptions_plan_id'

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :name,           presence: true
  validates :amount,         presence: true
  validates :interval,       presence: true
  validates :stripe_plan_id, uniqueness: true

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Retrieve the Stripe Plan.
  #
  # @return nil or a Stripe::Plan
  def stripe_plan
    return nil if stripe_plan_id.nil?

    Stripe::Plan.retrieve(stripe_plan_id)
  end

  # TODO: Better name.
  # Subscribe a structure to the current plan.
  #
  # @return nil or the new Subscription
  def subscribe!(structure)
    customer     = structure.stripe_customer
    subscription = customer.subscriptions.create(plan: self.stripe_plan_id)

    self.subscriptions.create(stripe_subscription_id: subscription.id, structure: structure)
  end
end
