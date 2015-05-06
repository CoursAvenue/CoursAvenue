class Subscriptions::Plan < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Constants                                                          #
  ######################################################################

  TRIAL_LENGTH = 14
  INTERVALS = {
    month: 'Mensuel',
    year: 'Annuel'
  }

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :name, :public_name, :amount, :interval, :stripe_plan_id, :trial_period_days

  has_many :subscriptions, foreign_key: 'subscriptions_plan_id'

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :name,     presence: true, uniqueness: true
  validates :amount,   presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true

  # validate :plan_not_already_on_stripe, on: :create

  ######################################################################
  # Callbacks                                                          #
  ######################################################################

  after_create :create_stripe_plan

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  scope :monthly, -> { where(interval: 'month').order('created_at ASC') }
  scope :yearly,  -> { where(interval: 'year').order('created_at ASC')}

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

  # Update the plan on Stripe.
  # It only updates the plan's name on Stripe.
  #
  # @return the Stripe::Plan
  def update_stripe_plan!
    plan = stripe_plan
    plan.name = self.name
    plan.save

    plan
  end

  # Delete the plan from Stripe
  #
  # @return a Boolean
  def delete_stripe_plan!
    plan = stripe_plan
    return nil if plan.nil?

    plan.delete
    self.stripe_plan_id = nil

    save
  end

  # Subscribe a structure to the current plan.
  #
  # @param structure    The structure that subscribes to the plan.
  # @param coupon_code  The coupon code to apply to the subscription
  # @param trial_period The trial period, by default 15 days.
  #
  # @return nil or the new Subscription
  def create_subscription!(structure, coupon_code = nil, trial_period = 15.days.ago)
    options = {
      plan: self.stripe_plan_id
    }

    coupon = Subscriptions::Coupon.where(stripe_coupon_id: coupon_code).first
    if coupon.present? and coupon.valid?
      options.merge!({ coupon: coupon.stripe_coupon_id })
    end

    # TODO: add Intercom event
    # begin
    #   Intercom::Event.create(event_name: "Confirmed account",
    #                          created_at: Time.now.to_i,
    #                          email: structure.email,
    #                          user_id: "Admin_#{structure.id}")
    # rescue
    #   Bugsnag.notify(RuntimeError.new("Can't sync with Intercom after confirmation"), {email: self.email})
    # end

    self.subscriptions.create({
      structure: structure,
      coupon:    coupon,
      trial_end: TRIAL_LENGTH.days.from_now
    })
  end

  # Return the plan URL on Stripe.
  #
  # @return nil or a String.
  def stripe_plan_url
    return nil if stripe_plan_id.nil?

    "https://dashboard.stripe.com/#{ Rails.env.production? ? '' : 'test/' }plans/#{ stripe_plan_id }"
  end

  private

  # Create a new Stripe Plan and save the Stripe Plan id.
  #
  # @return the Stripe::Plan
  def create_stripe_plan
    return false if name.nil?

    plan_id = "#{name.parameterize}-#{id}"
    options = {
      id:       plan_id,
      amount:   amount * 100,
      currency: Subscription::CURRENCY,
      interval: interval,
      name:     name
    }

    if trial_period_days.present?
      options.merge!(trial_period_days: trial_period_days)
    end

    plan = Stripe::Plan.create(options)

    self.stripe_plan_id = plan_id
    save

    plan
  end

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
