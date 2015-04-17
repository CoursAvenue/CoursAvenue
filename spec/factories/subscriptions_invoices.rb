FactoryGirl.define do
  factory :subscriptions_invoice, class: 'Subscriptions::Invoice' do
    structure
    subscription
  end
end
