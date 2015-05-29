# Creates a legal entity fixture.
#
# @param structure The structure from which is created the legal entity.
#
# @return Hash
def create_legal_entity(structure)
  dob = 35.years.ago
  entity = {
    address: {
      line1:       Faker::Address.street_address,
      line2:       Faker::Address.secondary_address,
      city:        Faker::Address.city,
      state:       Faker::Address.state,
      postal_code: Faker::Address.zip,
      country:     'FR',
    },
    dob: {
      day:   dob.day,
      month: dob.month,
      year:  dob.year,
    },
    personal_address: {
      line1:       Faker::Address.street_address,
      city:        Faker::Address.city,
      state:       Faker::Address.state,
      postal_code: Faker::Address.zip,
      country:     'FR',
    },
    business_name: structure.name,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    type: ['individual', 'company'].sample,
    additional_owners: create_additional_owners
  }
  entity
end

def create_additional_owners
  nil
end
