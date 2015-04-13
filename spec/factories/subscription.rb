FactoryGirl.define do
  factory :subscription do
    structure { FactoryGirl.create(:structure, :with_stripe_customer) }
    stripe_subscription_id ''

    factory :empty_subscription do
      stripe_subscription_id nil
    end

    trait :canceled do
      canceled_at 10.days.ago
    end
  end
end
