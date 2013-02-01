# -*- encoding : utf-8 -*-


FactoryGirl.define do
  factory :structure do
    name { Forgery::Name.full_name + ' institute' }

    trait :at_nice do
      after_build do |structure|
        structure.city = Factory.build(:city_nice)
      end
    end
    trait :at_paris do
      after_build do |structure|
        structure.city = Factory.build(:city_paris)
      end
    end
    factory :structure_at_nice, :traits => [:at_nice]
    factory :structure_at_paris, :traits => [:at_paris]
  end
end
