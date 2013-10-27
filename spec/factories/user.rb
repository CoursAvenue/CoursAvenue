# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :user do
    name     Faker::Name.name

    # email    Faker::Internet.email
    sequence :email do |n|
      "person#{n}@example.com"
    end

    password                'password'
    password_confirmation   'password'
  end
end
