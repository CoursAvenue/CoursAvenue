# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :user do

    first_name     Forgery::Name.first_name
    last_name      Forgery::Name.last_name
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password                'password'
    password_confirmation   'password'
  end
end
