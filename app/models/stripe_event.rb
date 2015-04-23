class StripeEvent < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  # https://stripe.com/docs/api/ruby#event_types
  SUPPORTED_EVENTS = [
    'invoice.payment_succeeded',
    'invoice.payment_failed',

    'ping'
  ]

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :stripe_event_id, :event_type

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :stripe_event_id, presence: true
  validates :stripe_event_id, uniqueness: true
  validates :event_type,      presence: true

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Retrieve the event from Stripe.
  #
  # @return nil or a Stripe::Event.
  def stripe_event
    return nil if stripe_event_id.nil?

    Stripe::Event.retrieve(stripe_event_id)
  end

  # Check if an event has been processed
  #
  # @param stripe_event_object The event to check.
  #
  # @return a boolean
  def self.processed?(stripe_event_object)
    where(stripe_event_id: stripe_event_object.id).any?
  end

  # Save and process an event.
  #
  # @param stripe_event_object The event to process.
  #
  # @return a boolean
  def self.process!(stripe_event_object)
    return false if StripeEvent.processed?(stripe_event_object)

    stripe_event = create(stripe_event_id: stripe_event_object.id,
                          event_type:      stripe_event_object.type)
    stripe_event.process!
  end

  # Process the event.
  #
  # @return a Boolean
  def process!
    case event_type
    when 'invoice.payment_succeeded'            then create_invoice
    when 'invoice.payment_failed'               then cancel_subscription

    when 'ping'                                 then no_op
    else false
    end
  end

  private

  # Process for the `invoice.payment_succeeded` event.
  #
  # @return a Boolean
  def create_invoice
    stripe_invoice = stripe_event.data.object
    invoice = Subscriptions::Invoice.create_from_stripe_invoice(stripe_invoice)
    invoice.subscription.resume! if invoice.subscription.paused?

    true
  end

  # Process for the `invoice.payment_failed` event.
  #
  # @return a Boolean
  def cancel_subscription
    stripe_invoice = stripe_event.data.object

    invoice = Subscriptions::Invoice.create_from_stripe_invoice(stripe_invoice)
    invoice.subscription.pause!

    true
  end

  # No operation process.
  #
  # @return a Boolean
  def no_op
    true
  end
end
