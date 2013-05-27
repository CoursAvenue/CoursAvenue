# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :admin do

    structure

    name     Forgery::Name.full_name
    sequence :email do |n|
      "person#{n}@example.com"
    end
    confirmed_at Date.today
    password                'password'
    password_confirmation   'password'
  end
end
