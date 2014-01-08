# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :user_profile do
    first_name     Faker::Name.first_name
    last_name      Faker::Name.last_name

    # email    Faker::Internet.email
    sequence :email do |n|
      "person#{n}@example.com"
    end
  end
end
