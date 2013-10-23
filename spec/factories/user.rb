# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :user do
    name     Forgery::Name.full_name

    email Forgery(:internet).email_address

    password                'password'
    password_confirmation   'password'
  end
end
