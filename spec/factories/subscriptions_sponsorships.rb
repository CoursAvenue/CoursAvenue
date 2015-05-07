FactoryGirl.define do
  factory :subscriptions_sponsorship, class: 'Subscriptions::Sponsorship' do
    consumed        false
    sponsored_email { Faker::Internet.email }
  end
end
