# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :structure do
    city
    name           Faker::Name.name + ' institute'

    street         Faker::Address.street_address
    zip_code       75014
    structure_type Structure::STRUCTURE_TYPES.sample

    after(:build) do |structure|
      structure.subjects << FactoryGirl.build(:subject)
      structure.subjects << FactoryGirl.build(:subject_children)
    end

    factory :structure_with_admin do
      after(:build) do |structure|
        structure.admins << FactoryGirl.build(:admin)
      end
    end
    factory :structure_with_place do
      after(:create) do |structure|
        structure.places << FactoryGirl.build(:place)
        structure.save
        structure.index
      end
    end
  end
end
