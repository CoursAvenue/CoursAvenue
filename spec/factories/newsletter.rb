FactoryGirl.define do
  factory :newsletter do
    structure

    title   { Faker::Name.name }

    trait :sent do
      state 'sent'
    end
  end
end
