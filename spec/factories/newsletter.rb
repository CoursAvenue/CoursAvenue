FactoryGirl.define do
  factory :newsletter do
    structure
    association :mailing_list, factory: :newsletter_mailing_list

    title     { Faker::Name.name }
    layout_id { (1..5).to_a.sample }

    trait :sent do
      state 'sent'
    end

    trait :without_mailing_list do
      mailing_list nil
    end
  end
end
