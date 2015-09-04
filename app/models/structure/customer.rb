# TODO: Find a better name.
class Structure::Customer < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :structure

  has_one :subscription
  has_many :invoices, class_name: 'Subscription::Invoice'

  delegate :email, to: :structure, prefix: true
  delegate :name,  to: :structure, prefix: true

  before_destroy :delete_stripe_customer

  # Retrieve the Stripe customer associated with this user.
  #
  # @return a Stripe::Customer or nil
  def stripe_customer
    return nil if stripe_customer_id.nil?

    Stripe::Customer.retrieve(stripe_customer_id)
  end

  # Create a new Stripe customer.
  # The stripe customer is the stripe account used for the subscription with CoursAvenue.
  #
  # @param token The card token gotten from the Stripe.js.
  #
  # @return a Stripe::Customer or nil
  def create_stripe_customer(token)
    return nil if token.nil?

    description = "Compte client pour la structure #{ structure_name } (id = #{ id })"
    metadata = {
      structure_id: structure_id
    }

    stripe_customer = Stripe::Customer.create({
      description: description,
      source: token,
      metadata: metadata
    })

    self.stripe_customer_id = stripe_customer.id
    self.save

    stripe_customer
  end

  # TODO: Find a better name for this.
  # Wether the customer is on stripe and has an active subscription
  #
  # @return boolean
  def active?
    stripe_customer and subscription and subscription.active?
  end

  private

  def delete_stripe_customer
    return if stripe_customer_id.nil?

    stripe_customer.delete
  end
end
