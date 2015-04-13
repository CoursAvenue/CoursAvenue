FactoryGirl.define do
  factory :subscription do
    stripe_subscription_id ''

    trait :canceled do
      canceled_at 10.days.ago
    end
  end
end
