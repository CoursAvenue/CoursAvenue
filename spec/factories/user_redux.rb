# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :user_redux, class: User do
    email        { Faker::Internet.email }
    confirmed_at nil
  end
end
