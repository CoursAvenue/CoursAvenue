# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :user do
    first_name     { Faker::Name.first_name }
    last_name      { Faker::Name.last_name }

    confirmed_at   Time.now

    email    { Faker::Internet.email }

    password                'password'
    password_confirmation   'password'
  end
end
