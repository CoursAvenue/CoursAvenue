# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :city_paris, class: City do
    name        'Paris'
    short_name  'paris'
  end

  factory :city_nice, class: City do
    name        'Nice'
    short_name  'nice'
  end
end
