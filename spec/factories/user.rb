# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :user do
    name     Forgery::Name.full_name

    # email Forgery(:internet).email_address
    sequence :email do |n|
      "person#{n}@example.com"
    end

    password                'password'
    password_confirmation   'password'
  end
end
