FactoryGirl.define do
  factory :subscriptions_plan, class: 'Subscriptions::Plan' do
    name           { Faker::Name.name }
    amount_unit    { (15..30).to_a.sample }
    amount_cents   0
    interval       [ :month, :year ].sample
    stripe_plan_id { "#{name.parameterize}" }

    trait :gold_plan do
      name           'Gold'
      amount_unit    30
      amount_cents   0
      interval       :month
      stripe_plan_id 'gold_test_rspec'
    end

    trait :silver_plan do
      name           'Silver'
      amount_unit    15
      amount_cents   0
      interval       :month
      stripe_plan_id 'silver_test_rspec'
    end

    trait :empty do
      name nil
      stripe_plan_id nil
    end

    trait :monthly do
      interval :month
    end

    trait :yearly do
      interval :year
    end
  end
end
