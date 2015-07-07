FactoryGirl.define do
  factory :guide do
    title Faker::Lorem.sentence
    description Faker::Lorem.paragraph(3)
  end
end
