FactoryGirl.define do
  factory :subscription do
    stripe_subscription_id ''

    trait :canceled do
      canceled_at 10.days.ago
    end

    # factory :gold_plan do
    #   name 'Gold'
    #   price 3000
    #   interval :month
    #   stripe_subscription_id 'gold_test_rspec'
    # end
    #
    # factory :silver_plan do
    #   name 'Silver'
    #   price 1500
    #   interval :month
    #   stripe_subscription_id 'silver_test_rspec'
    # end
  end
end
