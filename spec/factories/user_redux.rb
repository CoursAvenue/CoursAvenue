# -*- encoding : utf-8 -*-

FactoryGirl.define do :user_redux do
  email        { Faker::Internet.email }
  confirmed_at nil
end
