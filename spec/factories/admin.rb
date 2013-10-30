# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :admin do

    structure

    name     Faker::Name.name
    sequence :email do |n|
      "person#{n}@example.com"
    end
    phone_number            '0104050104'
    mobile_phone_number     '0604050104'

    confirmed_at Date.today

    password                'zpdajdpzaojdxd'
    password_confirmation   'zpdajdpzaojdxd'
  end
end
