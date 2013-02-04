# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :city do
    name        'Paris'
    short_name  'paris'

    factory :city_nice do
      name        'Nice'
      short_name  'nice'
    end

  end
end
