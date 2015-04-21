FactoryGirl.define do
  factory :subscriptions_coupon, class: 'Subscriptions::Coupon' do
    name     Faker::Name.name
    amount   (1..50).to_a.sample
    duration Subscriptions::Coupon::DURATIONS.keys.sample.to_s

    trait :empty do
      stripe_coupon_id nil
    end
  end
end
