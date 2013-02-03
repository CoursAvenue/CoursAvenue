# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :structure do
    name { Forgery::Name.full_name + ' institute' }

    factory :structure_at_nice do
      after(:build) do |structure|
        structure.city = FactoryGirl.build(:city_nice)
      end
    end

    factory :structure_at_paris do
      after(:build) do |structure|
        structure.city = FactoryGirl.build(:city_paris)
      end
    end
  end
end
