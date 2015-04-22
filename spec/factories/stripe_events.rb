FactoryGirl.define do
  factory :stripe_event, class: 'StripeEvent' do
    stripe_event nil
    event_type   { StripeEvent::SUPPORTED_EVENTS.sample }
  end
end
