FactoryGirl.define do
  factory :subscription do
    association :plan, factory: :subscriptions_plan

    trait :canceled do
      canceled_at 10.days.ago
    end

    trait :paused do
      paused true
    end

  end
end
