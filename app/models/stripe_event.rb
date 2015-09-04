class StripeEvent < ActiveRecord::Base
  extend FriendlyId

  acts_as_paranoid
  friendly_id :stripe_event_id, use: [:finders]

  ######################################################################
  # Constants                                                          #
  ######################################################################

  # https://stripe.com/docs/api/ruby#event_types
  SUPPORTED_EVENTS = [
    'invoice.payment_succeeded',
    'invoice.payment_failed',

    'charge.dispute.created',
    'charge.dispute.funds_withdrawn',
    'charge.dispute.funds_reinstated',

    'customer.deleted',
    'customer.subscription.created',

    'account.updated',

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
  # Scopes                                                             #
  ######################################################################

  scope :processed,             -> { where(processed: true) }
  scope :not_processed,         -> { where(processed: false) }

  scope :not_in_the_last_month, -> { where( arel_table[:created_at].lt(1.month.ago) ) }

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
    event = where(stripe_event_id: stripe_event_object.id).first

    event.present? and event.processed?
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
    self.processed =
      case event_type
      when 'invoice.payment_succeeded'            then payment_succeeded
      when 'invoice.payment_failed'               then payment_failed

      when 'charge.dispute.created'               then dispute_created
      when 'charge.dispute.funds_withdrawn'       then dispute_funds_withdrawn
      when 'charge.dispute.funds_reinstated'      then dispute_funds_reinstated

      when 'customer.deleted'                     then delete_stripe_customer
      when 'customer.subscription.created'        then customer_subscription_created

      when 'account.updated'                      then account_updated

      when 'ping'                                 then no_op
      else false
      end
    save

    self.processed
  end

  private

  # Process for the `invoice.payment_succeeded` event.
  #
  # @return a Boolean
  def payment_succeeded
    stripe_invoice = stripe_event.data.object
    invoice = Subscriptions::Invoice.create_from_stripe_invoice(stripe_invoice)
    return false if invoice.nil?

    invoice.subscription.resume! if invoice.subscription.paused?
    SubscriptionMailer.delay.invoice_creation_notification(invoice)

    true
  end

  # Process for the `invoice.payment_failed` event.
  #
  # @return a Boolean
  def payment_failed
    stripe_invoice = stripe_event.data.object

    invoice = Subscriptions::Invoice.create_from_stripe_invoice(stripe_invoice)
    invoice.subscription.pause!

    true
  end

  # Process for the `charge.dispute.created` event.
  #
  # @return a Boolean
  def dispute_created
    dispute        = stripe_event.data.object
    dispute_reason = dispute.reason
    dispute_status = dispute.status

    charge = Stripe::Charge.retrieve(dispute.charge)

    customer = charge.customer
    customer = customer.id if customer.class != String

    structure = Structure::Customer.where(stripe_customer_id: customer).first

    if structure.present?
      subscription = structure.subscription

      SuperAdminMailer.delay.alert_charge_disputed(structure, dispute_reason, dispute_status)
      subscription.pause!
      true
    else
      false
    end
  end

  # Process for the `charge.dispute.funds_withdrawn` event.
  #
  # @return a Boolean
  def dispute_funds_withdrawn
    dispute        = stripe_event.data.object
    dispute_reason = dispute.reason
    dispute_status = dispute.status

    charge       = Stripe::Charge.retrieve(dispute.charge)

    customer = charge.customer
    customer = customer.id if customer.class != String

    structure = Structure.where(stripe_customer_id: customer).first

    if structure.present?
      subscription = structure.subscription

      SuperAdminMailer.delay.alert_charge_withdrawn(structure, dispute_reason, dispute_reason)
      SubscriptionMailer.delay.subscription_canceled(structure, subscription)
      subscription.cancel!
      true
    else
      false
    end
  end

  # Process for the `charge.dispute.funds_reinstated` event.
  #
  # @return a Boolean
  def dispute_funds_reinstated
    dispute        = stripe_event.data.object
    dispute_reason = dispute.reason
    dispute_status = dispute.status

    charge       = Stripe::Charge.retrieve(dispute.charge)
    charge       = Stripe::Charge.retrieve(dispute.charge)

    customer = charge.customer
    customer = customer.id if customer.class != String

    structure = Structure.where(stripe_customer_id: customer).first

    if structure.present?
      subscription = structure.subscription

      SuperAdminMailer.delay.alert_charge_reinstated(structure, dispute_reason, dispute_reason)
      subscription.cancel!
      true
    else
      false
    end
  end

  # Process for the `customer.deleted` event.
  #
  # @return a Boolean
  def delete_stripe_customer
    stripe_customer = stripe_event.data.object
    structure = Structure.where(stripe_customer_id: stripe_customer.id).first

    if structure.present?
      structure.stripe_customer_id = nil
      structure.save

      true
    else
      false
    end
  end

  # Process for the `customer.subscription.created` event.
  #
  # @return a Boolean
  def customer_subscription_created
    stripe_customer = stripe_event.data.object
    structure = Structure.where(stripe_customer_id: stripe_customer.id).first
    return false if structure.nil?

    customer_id = structure.stripe_customer_id
    invoice = Stripe::Invoice.upcoming(customer: customer_id) ||
      Stripe::Invoice.all(customer: customer_id, limit: 1).first
    return false if invoice.nil?

    Subscriptions::Invoice.create_from_stripe_invoice(invoice)
    true
  end

  # Process for the `account.updated` event.
  #
  # @return a Boolean
  def account_updated
    true
  end

  # No operation process.
  #
  # @return a Boolean
  def no_op
    true
  end
end
