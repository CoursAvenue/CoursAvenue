class StripeEvent < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  SUPPORTED_EVENTS = [
    'invoice.created'
  ]

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :stripe_event_id, :event_type

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validate :stripe_event_id, presence: true
  validate :stripe_event_id, uniqueness: true
  validate :event_type,      presence: true

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

  # Process an event.
  #
  # @param stripe_event_object The event to process.
  #
  # @return a boolean
  def self.process!(stripe_event_object)
    return false if StripeEvent.processed?(stripe_event_object)

    stripe_event = create(stripe_event_id: stripe_event_object.id,
                          event_type:      stripe_event_object.type)
  end

  def stripe_event
    return nil if stripe_event_id.nil?

    Stripe::Event.retrieve(stripe_event_id)
  end
end
