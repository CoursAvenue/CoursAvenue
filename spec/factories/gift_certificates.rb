FactoryGirl.define do
  factory :gift_certificate do
    structure

    name        { Faker::Name.name }
    amount      { (1..20).to_a.sample.to_f }
    description { Faker::Lorem.sentence }
  end
end
