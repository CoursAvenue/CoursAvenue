class Subscriptions::Plan < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Constants                                                          #
  ######################################################################

  INTERVALS = {
    month: 'Mensuel',
    year: 'Annuel'
  }

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :name, :amount, :interval

  has_many :subscriptions, foreign_key: 'subscriptions_plan_id'

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :name,           presence: true, uniqueness: true
  validates :amount,         presence: true
  validates :interval,       presence: true
  validates :stripe_plan_id, uniqueness: true

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  scope :monthly, -> { where(interval: 'month') }
  scope :yearly,  -> { where(interval: 'year') }

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

  # TODO: Remove explicit api key.
  # Subscribe a structure to the current plan.
  #
  # @return nil or the new Subscription
  def create_subscription!(structure, token = nil)
    customer     = structure.stripe_customer || structure.create_stripe_customer(token)
    subscription = customer.subscriptions.create({ plan: self.stripe_plan_id }, { api_key: Stripe.api_key })

    self.subscriptions.create(stripe_subscription_id: subscription.id, structure: structure)
  end
end
