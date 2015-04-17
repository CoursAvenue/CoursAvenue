class Subscriptions::Plan < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Constants                                                          #
  ######################################################################

  INTERVALS = {
    month: 'Mensuel',
    year: 'Annuel'
  }

  CURRENCY = 'EUR'

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :name, :amount, :interval, :stripe_plan_id, :trial_period_days

  has_many :subscriptions, foreign_key: 'subscriptions_plan_id'

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :name,           presence: true, uniqueness: true
  validates :amount,         presence: true
  validates :interval,       presence: true

  # validate :plan_not_already_on_stripe, on: :create

  ######################################################################
  # Callbacks                                                          #
  ######################################################################

  after_create :create_stripe_plan

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  scope :monthly, -> { where(interval: 'month') }
  scope :yearly,  -> { where(interval: 'year') }

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # TODO: Know whether the plan is active or not.

  # Retrieve the Stripe Plan.
  #
  # @return nil or a Stripe::Plan
  def stripe_plan
    return nil if stripe_plan_id.nil?

    Stripe::Plan.retrieve(stripe_plan_id, { api_key: Stripe.api_key })
  end

  # Delete the plan from Stripe
  #
  # @return
  def delete_stripe_plan!
    plan = stripe_plan
    return nil if plan.nil?

    plan.delete({ api_key: Stripe.api_key })
    self.stripe_plan_id = nil

    save
  end

  # TODO: Remove explicit api key.
  # Subscribe a structure to the current plan.
  #
  # @return nil or the new Subscription
  def create_subscription!(structure, token = nil)
    customer     = structure.stripe_customer || structure.create_stripe_customer(token)
    return nil if customer.nil?

    # TODO: Remove explicit api key.
    subscription = customer.subscriptions.create({ plan: self.stripe_plan_id }, { api_key: Stripe.api_key })

    self.subscriptions.create(stripe_subscription_id: subscription.id, structure: structure)
  end

  private

  # Create a new Stripe Plan and save the Stripe Plan id.
  #
  # @return the Stripe::Plan
  def create_stripe_plan
    return false if name.nil?

    plan_id = self.name.parameterize
    plan = Stripe::Plan.create({
      id:                plan_id,
      amount:            self.amount,
      currency:          CURRENCY,
      interval:          self.interval,
      name:              self.name,
      trial_period_days: self.trial_period_days || 0
    })

    self.stripe_plan_id = plan_id
    save

    plan
  end

  handle_asynchronously :create_stripe_plan

  # Validates that the plan doesn't already exist on Stripe.
  # If it throws a `Stripe::InvalidRequestError`, it means the Plan doesn't exist and we can
  # proceed. Otherwise, it will add the validation error.
  #
  # @return
  def plan_not_already_on_stripe
    plan_id = name.parameterize
    plan = Stripe::Plan.retrieve(plan_id)

    errors.add(:stripe_plan_id, "Stripe Plan already exists")
  rescue Stripe::InvalidRequestError => e
  end
end
