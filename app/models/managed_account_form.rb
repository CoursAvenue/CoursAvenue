class ManagedAccountForm
  include ActiveModel::Model
  include Virtus.model

  attr_accessor :stripe_bank_token, :structure_id, :bank_account_number, :tos_acceptance_ip,
    :address_line1, :address_line2, :address_city, :address_state,
    :address_postal_code, :address_country, :business_type, :business_name, :business_url,
    :business_address_line1, :business_address_line2, :business_name, :business_address_line1,
    :business_address_line2, :business_address_city, :business_address_state,
    :business_address_postal_code,

    :owner_first_name, :owner_last_name, :owner_dob, :owner_dob_day, :owner_dob_month,
    :owner_dob_year, :owner_address_line1, :owner_address_line2, :owner_address_city,
    :owner_address_state, :owner_address_postal_code, :owner_address_country,

    :additional_owner_0_first_name, :additional_owner_0_last_name, :additional_owner_0_dob,
    :additional_owner_0_dob_day, :additional_owner_0_dob_month, :additional_owner_0_dob_year,
    :additional_owner_0_address_line1, :additional_owner_0_address_line2,
    :additional_owner_0_address_city, :additional_owner_0_address_postal_code,
    :additional_owner_0_address_state, :additional_owner_0_address_country,

    :additional_owner_1_first_name, :additional_owner_1_last_name, :additional_owner_1_dob,
    :additional_owner_1_dob_day, :additional_owner_1_dob_month, :additional_owner_1_dob_year,
    :additional_owner_1_address_line1, :additional_owner_1_address_line2,
    :additional_owner_1_address_city, :additional_owner_1_address_postal_code,
    :additional_owner_1_address_state, :additional_owner_1_address_country,

    :additional_owner_2_first_name, :additional_owner_2_last_name, :additional_owner_2_dob,
    :additional_owner_2_dob_day, :additional_owner_2_dob_month, :additional_owner_2_dob_year,
    :additional_owner_2_address_line1, :additional_owner_2_address_line2,
    :additional_owner_2_address_city, :additional_owner_2_address_postal_code,
    :additional_owner_2_address_state, :additional_owner_2_address_country

  attribute :stripe_bank_token, String
  validates :stripe_bank_token, presence: true

  attribute :structure_id, Integer
  validates :structure_id, presence: true

  # "Save" the managed account form.
  # We don't really save the object, but persist the attributes of the object in the related Models,
  # here the structure model.
  #
  # @return Boolean, whether the object has been "saved".
  def save
    valid? ? persist! : false
  end

  private

  # Create the managed account if every needed information is given.
  #
  # @return a Boolean, whether the managed account was created or not.
  def persist!
    @structure = Structure.find(structure_id)

    managed_account_options = {
      legal_entity: legal_entity,
      bank_account: stripe_bank_token,
      tos_acceptance: {
        date: Time.now.to_i,
        ip: tos_acceptance_ip
      }
    }

    @structure.create_managed_account(managed_account_options)
  end

  # Format the legal entity of the managed account.
  #
  # @return a Hash.
  def legal_entity
    owner_dob_day, owner_dob_month, owner_dob_year = owner_dob.split('/').map(&:to_i)

    {
      address: {
        line1:       business_address_line1,
        line2:       business_address_line2,
        city:        business_address_city,
        state:       business_address_state,
        postal_code: business_address_postal_code,
        country:     'FR',
      },
      dob: {
        day:   owner_dob_day,
        month: owner_dob_month,
        year:  owner_dob_year,
      },
      personal_address: {
        line1:       owner_address_line1,
        city:        owner_address_city,
        state:       owner_address_state,
        postal_code: owner_address_postal_code,
        country:     'FR',
      },
      business_name: business_name,
      # business_url:  business_url,
      first_name:    owner_first_name,
      last_name:     owner_last_name,
      type:          business_type,
      additional_owners: additional_owners
    }
  end

  # Format the additional owners.
  # In case there are no additional owners, we return an empty string.
  # <https://stripe.com/docs/connect/updating-accounts#additional-owners>
  #
  # @return an Array or an empty String.
  def additional_owners
    if ! additional_owner_0_first_name.present?
      owner_0 = nil
    else
      additional_owner_0_dob_day, additional_owner_0_dob_month, additional_owner_0_dob_year =
        additional_owner_0_dob.split('/').map(&:to_i)

      owner_0 = {
        first_name: additional_owner_0_first_name,
        last_name:  additional_owner_0_last_name,
        dob: {
          day:   additional_owner_0_dob_day,
          month: additional_owner_0_dob_month,
          year:  additional_owner_0_dob_year,
        },
        address: {
          line1:       additional_owner_0_address_line1,
          line2:       additional_owner_0_address_line2,
          city:        additional_owner_0_address_city,
          state:       additional_owner_0_address_state,
          postal_code: additional_owner_0_address_postal_code,
          country:     'FR',
        },
      }
    end

    if ! additional_owner_1_first_name.present?
      owner_1 = nil
    else
      additional_owner_1_dob_day, additional_owner_1_dob_month, additional_owner_1_dob_year =
        additional_owner_1_dob.split('/').map(&:to_i)

      owner_1 = {
        first_name: additional_owner_1_first_name,
        last_name:  additional_owner_1_last_name,
        dob: {
          day:   additional_owner_1_dob_day,
          month: additional_owner_1_dob_month,
          year:  additional_owner_1_dob_year,
        },
        address: {
          line1:       additional_owner_1_address_line1,
          line2:       additional_owner_1_address_line2,
          city:        additional_owner_1_address_city,
          state:       additional_owner_1_address_state,
          postal_code: additional_owner_1_address_postal_code,
          country:     'FR',
        },
      }
    end

    if ! additional_owner_1_first_name.present?
      owner_2 = nil
    else
      additional_owner_2_dob_day, additional_owner_2_dob_month, additional_owner_2_dob_year =
        additional_owner_2_dob.split('/').map(&:to_i)

      owner_2 = {
        first_name: additional_owner_2_first_name,
        last_name:  additional_owner_2_last_name,
        dob: {
          day:   additional_owner_2_dob_day,
          month: additional_owner_2_dob_month,
          year:  additional_owner_2_dob_year,
        },
        address: {
          line1:       additional_owner_2_address_line1,
          line2:       additional_owner_2_address_line2,
          city:        additional_owner_2_address_city,
          state:       additional_owner_2_address_state,
          postal_code: additional_owner_2_address_postal_code,
          country:     'FR',
        },
      }
    end

    owners = [owner_0, owner_1, owner_2].compact

    owners.empty? ? '' : owners
  end

end
