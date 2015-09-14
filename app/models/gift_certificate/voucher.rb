class GiftCertificate::Voucher < ActiveRecord::Base
  include Concerns::HasRandomToken

  attr_accessor :name, :email, :stripe_token

  belongs_to :gift_certificate
  belongs_to :user

  delegate :amount, :structure,:description, to: :gift_certificate
  delegate :name, to: :gift_certificate, prefix: true

  # Retrieve the `Stripe::Charge` associated with the voucher.
  #
  # @return nil or Stripe::Charge
  def stripe_charge
    return nil if stripe_charge_id.nil?

    Stripe::Charge.retrieve(stripe_charge_id)
  end

  # Charge the amount of the voucher to the user.
  #
  # @param token The token needed to create the stripe customer, if it doesn't already exists.
  #
  # @return the charge or nil
  def charge!(token = nil)
    return nil if !structure.can_receive_payments?

    customer = user.stripe_customer || user.create_stripe_customer(token)
    return nil if customer.nil?

    charge = Stripe::Charge.create({
      amount:   amount.to_i * 100,
      currency: GiftCertificate::CURRENCY,
      customer: customer.id,
      destination: structure.stripe_managed_account
    })

    self.stripe_charge_id = charge.id
    self.save

    send_emails
    self.delay.retrieve_fees

    charge
  end

  # Whether the voucher has been charged to the user.
  #
  # @return a Boolean
  def charged?
    stripe_charge_id.present?
  end

  def use!
    self.used = true
    save
  end

  private

  def send_emails
    GiftCertificateMailer.delay(queue: 'mailers').voucher_confirmation_to_user(self)
    GiftCertificateMailer.delay(queue: 'mailers').voucher_created_to_teacher(self)
  end

  # Create a uniq random token.
  # We generate a UUID like: `2d931510-d99f-494a-8c67-87feb05e1594` and then split it to make it
  # friendlier than generating purely random string.
  #
  # @return
  def create_token
    if self.token.nil?
      self.token = loop do
        random_token = "BON-#{SecureRandom.uuid.split('-').first}"
        break random_token unless self.class.exists?(token: random_token)
      end
    end
  end

  # Retrieve the different fees from Stripe after the charge.
  #
  # @return
  def retrieve_fees
    return if stripe_charge_id.nil?

    transaction = Stripe::BalanceTransaction.retrieve(stripe_charge.balance_transaction)
    return if transaction.nil?

    self.fee             = transaction.fee / 100.0
    self.received_amount = transaction.net / 100.0
    save
  end
end
