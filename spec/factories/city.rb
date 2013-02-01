# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :city do

    factory :city_paris do
      name        'Paris'
      short_name  'paris'
    end

    factory :city_nice do
      name        'Nice'
      short_name  'nice'
    end
  end
end
