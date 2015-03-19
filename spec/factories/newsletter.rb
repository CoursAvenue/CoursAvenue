FactoryGirl.define do
  factory :newsletter do
    structure

    title     { Faker::Name.name }
    layout_id { (1..5).to_a.sample }

    trait :sent do
      state 'sent'
    end
  end
end
