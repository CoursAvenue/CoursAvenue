# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :user_redux do
    email        { Faker::Internet.email }
    confirmed_at nil
  end
end
