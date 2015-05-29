FactoryGirl.define do
  factory :subscriptions_plan, class: 'Subscriptions::Plan' do
    name           { Faker::Name.name }
    amount         { (15..30).to_a.sample }
    interval       [ 'month', 'year' ].sample
    stripe_plan_id { "#{name.parameterize}" }
    plan_type      { Subscriptions::Plan::PLAN_TYPES.sample }
    public_name    { Faker::Name.name }

    trait :gold_plan do
      name           'Gold'
      amount         30
      interval       :month
      stripe_plan_id 'gold_test_rspec'
    end

    trait :silver_plan do
      name           'Silver'
      amount         15
      interval       :month
      stripe_plan_id 'silver_test_rspec'
    end

    trait :empty do
      name nil
      stripe_plan_id nil
    end

    trait :monthly do
      interval 'month'
    end

    trait :yearly do
      interval 'year'
    end

    trait :with_trial_period do
      trial_period_days 30
    end
  end
end
