
# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :admin do
    structure

    name     { Faker::Name.name + rand.to_s }
    email    { Faker::Internet.email}
    password                'zpdajdpzaojdxd'
    password_confirmation   'zpdajdpzaojdxd'

    phone_number            '0104050104'
    mobile_phone_number     '0604050104'

    confirmed_at { Date.today }

    after(:build) do |admin|
      admin.structure = FactoryGirl.create(:structure)
    end

    trait :from_facebook do
      uid              { Faker::Number.number(6) }
      oauth_token      { Faker::Internet.password }
      oauth_expires_at { 10.years.from_now }
      provider         'facebook'
    end

    factory :admin_from_facebook, traits: [:from_facebook]

    factory :super_admin do
      super_admin true
    end
  end
end
