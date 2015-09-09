class Payment::Merchant < ActiveRecord::Base
  belongs_to :structure

  delegate :name,  to: :structure, allow_nil: true, prefix: true
  delegate :email, to: :structure, allow_nil: true, prefix: true

  def stripe_managed_account
    return nil if stripe_managed_account_id.nil?
    Stripe::Account.retrieve(stripe_managed_account_id)
  end

  # Retrieve the Stripe managed account.
  #
  # @return nil or a Stripe::Account
  def stripe_managed_account
    return nil if self.stripe_managed_account_id.nil?

    Stripe::Account.retrieve(self.stripe_managed_account_id)
  end

  # Create the stripe manged account.
  # More information: <https://stripe.com/docs/api/ruby#account_object>
  #
  # @param options The option for the creation of the managed account.
  # In the options, we are waiting for:
  #  * legal_entity: a hash
  #
  #  * bank_account: either a Stripe token or a hash with
  #    - The country of the bank account (country),
  #    - The currency of the bank account (currency) (Must be in the supported currencies
  #      <https://support.stripe.com/questions/which-currencies-does-stripe-support>
  #    - The account number of the bank account (account_number).
  #
  #  * tos_acceptance: a hash with the details on Stripe's TOS acceptance:
  #    - The date as a UNIX timestamp (date).
  #    - The ip address from which Stripe’s TOS were agreed (ip).
  #
  # @raise Payment::MissingBankAccount
  # @return nil or a Stripe::Account
  def create_managed_account(options = {})
    return stripe_managed_account if stripe_managed_account_id.present?
    # TODO Raise
    return false                  if options[:bank_account].nil?

    default_options = {
      managed: true,
      country: 'FR',
      email: structure_email,
      business_name: structure_name,
      metadata: {
        structure: structure_id
      }
    }

    managed_account = Stripe::Account.create(options.merge(default_options))

    self.stripe_managed_account_id              = managed_account.id
    self.stripe_managed_account_secret_key      = managed_account.keys.secret
    self.stripe_managed_account_publishable_key = managed_account.keys.publishable
    save

    managed_account
  end

  # Update the managed account.
  #
  # This uses `[]` to access and update the managed account attributes. Hopefully, this doesn't
  # break in the future /shrug.
  #
  # Furthermore, if this method is called while the managed_account is still in cache from its
  # creation, the `keys` accessor corresponds to the `keys` attributes, containing the secret and
  # publishable keys (https://stripe.com/docs/api/ruby#create_account) for this account instead
  # of the `keys` methods.
  #
  # @param options The attributes to update.
  #
  # @return the Stripe::Account or nil
  def update_managed_account(options)
    return nil if self.stripe_managed_account_id.nil? or options.nil? or options.empty?
    managed_account = self.stripe_managed_account

    options.keys.each do |key|
      sym_key = key.to_sym
      if managed_account.keys.include?(sym_key) or managed_account.methods.include?(sym_key)
        managed_account[sym_key] = options[key]
        options.delete(key)
      end
    end

    if options.any? and options.include?('owner_dob_day')
      managed_account.legal_entity.dob.day   = options['owner_dob_day'].to_i
      managed_account.legal_entity.dob.month = options['owner_dob_month'].to_i
      managed_account.legal_entity.dob.year  = options['owner_dob_year'].to_i
    end

    managed_account.save
  end

  # Whether the structure can receive payments through its Stripe managed account.
  #
  # @return a Boolean
  def can_receive_payments?
    return false if self.stripe_managed_account_id.nil?
    managed_account = self.stripe_managed_account

    managed_account.charges_enabled and managed_account.transfers_enabled
  end
end
