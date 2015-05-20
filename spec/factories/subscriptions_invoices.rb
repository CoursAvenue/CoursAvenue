FactoryGirl.define do
  factory :subscriptions_invoice, class: 'Subscriptions::Invoice' do
    structure
    subscription

    trait :payed do
      payed_at { 1.day.ago }
    end
  end
end
