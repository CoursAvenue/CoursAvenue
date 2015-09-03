FactoryGirl.define do
  factory :payment_customer, :class => 'Payment::Customer' do
    trait :with_user do
      association :client, factory: :user
    end

    trait :with_structure do
      association :client, factory: :structure_with_admin
    end
  end
end
