FactoryGirl.define do
  factory :newsletter do
    structure

    title   { Faker::Name.name }
    content { Faker::Lorem.paragraph(2) }

    trait :sent do
      state 'sent'
    end
  end
end
