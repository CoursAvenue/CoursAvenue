FactoryGirl.define do
  factory :newsletter do
    structure

    title     { Faker::Name.name }
    layout_id { (0..4).to_a.sample }

    trait :sent do
      state 'sent'
    end
  end
end
