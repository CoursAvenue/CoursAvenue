class StripeEvent < ActiveRecord::Base

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :stripe_event_id

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validate :stripe_event_id, presence: true
  validate :stripe_event_id, uniqueness: true

  ######################################################################
  # Methods                                                            #
  ######################################################################

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

    stripe_event = create(stripe_event_id: stripe_event_object.id)
  end

  def stripe_event
    return nil if stripe_event_id.nil?

    Stripe::Event.retrieve(stripe_event_id)
  end
end
