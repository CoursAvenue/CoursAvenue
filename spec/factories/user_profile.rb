# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :user_profile do
      structure
    first_name     Faker::Name.first_name
    last_name      Faker::Name.last_name

    # email    Faker::Internet.email
    sequence :email do |n|
      "person#{n}@example.com"
    end

    factory :user_profile_with_tags do
      after(:build) do |user_profile|

        tags = ["allergic to cats", "completely insane"]
        user_profile.structure.tag(user_profile, with: tags, on: :tags)
        user_profile.structure.save
      end
    end
  end
end
