FactoryGirl.define do
  factory :structure_customer, class: 'Structure::Customer' do
    structure
    # stripe_customer_id nil
  end
end
