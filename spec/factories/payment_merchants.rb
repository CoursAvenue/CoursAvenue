FactoryGirl.define do
  factory :payment_merchant, :class => 'Payment::Merchant' do
    association :structure
  end
end
