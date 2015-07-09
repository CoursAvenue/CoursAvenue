FactoryGirl.define do
  factory :guide do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph(3) }
    call_to_action { Faker::Lorem.sentence }
  end
end
