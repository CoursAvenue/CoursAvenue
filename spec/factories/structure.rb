# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :structure do
    city FactoryGirl.create(:city_paris)

    name { Forgery::Name.full_name + ' institute' }
    street     'Super street'
    zip_code   75000
    structure_type 'structures.association'

  end
end
