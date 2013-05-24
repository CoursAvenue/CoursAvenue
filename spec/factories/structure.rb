# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :structure do
    city FactoryGirl.create(:city_paris)

    name       { Forgery::Name.full_name + ' institute' }
    # street     Forgery(:lorem_ipsum).words(5)
    street     Forgery(:address).street_address
    zip_code   75014
    structure_type Structure::STRUCTURE_TYPES.sample

  end
end
