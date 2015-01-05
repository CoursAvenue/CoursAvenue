# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :user do
    first_name     { Faker::Name.first_name }
    last_name      { Faker::Name.last_name }
    email_opt_in   true
    confirmed_at   Time.now

    email    { Faker::Internet.email }

    password                'password'
    password_confirmation   'password'

    factory :user_from_facebook do
      oauth_token      { Faker::Internet.password }
      oauth_expires_at { 10.years.from_now }
      provider         'facebook'
    end
  end
end
