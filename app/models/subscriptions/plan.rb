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

  attr_accessible :name, :amount, :interval, :stripe_plan_id

  has_many :subscriptions, foreign_key: 'subscriptions_plan_id'

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :name,           presence: true, uniqueness: true
  validates :amount,         presence: true
  validates :interval,       presence: true
  # validates :stripe_plan_id, uniqueness: true

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
      id:       plan_id,
      amount:   self.amount,
      currency: CURRENCY,
      interval: self.interval,
      name:     self.name
    })

    self.stripe_plan_id = plan_id
    save

    plan
  end

  handle_asynchronously :create_stripe_plan
end
