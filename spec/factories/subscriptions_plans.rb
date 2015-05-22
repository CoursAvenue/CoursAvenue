FactoryGirl.define do
  factory :subscriptions_plan, class: 'Subscriptions::Plan' do
    name           { Faker::Name.name }
    amount         { (15..30).to_a.sample }
    interval       [ 'month', 'year' ].sample
    stripe_plan_id { "#{name.parameterize}" }
    plan_type      { Subscriptions::Plan::PLAN_TYPES.sample }
    public_name    { Faker::Name.name }

    trait :monthly do
      interval 'month'
    end

    trait :yearly do
      interval 'year'
    end

    trait :module do
      plan_type 'module'
    end

    trait :website do
      plan_type 'website'
    end

    trait :with_trial_period do
      trial_period_days 30
    end
  end
end
