FactoryGirl.define do
  factory :subscriptions_plan, class: 'Subscriptions::Plan' do
    trait :gold_plan do
      name 'Gold'
      amount 3000
      interval :month
      stripe_plan_id 'gold_test_rspec'
    end

    trait :silver_plan do
      name 'Silver'
      amount 1500
      interval :month
      stripe_plan_id 'silver_test_rspec'
    end
  end
end
