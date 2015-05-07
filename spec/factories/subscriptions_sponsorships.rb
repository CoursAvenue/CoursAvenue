FactoryGirl.define do
  factory :subscriptions_sponsorship, class: 'Subscriptions::Sponsorship' do
    redeemed        false
    sponsored_email { Faker::Internet.email }
  end
end
