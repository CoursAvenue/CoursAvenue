FactoryGirl.define do
  factory :participation_request_state, :class => 'ParticipationRequest::State' do

    state "pending"
    # events []
    accepted_at nil
    treated_at nil
    canceled_at nil

    trait :accepted_state do
      state 'accepted'
      accepted_at 1.hour.ago
    end

    trait :canceled_state do
      state 'canceled'
      canceled_at 1.hour.ago
    end

    trait :treated_state do
      state 'treated'
      treated_at 1.hour.ago
    end
  end
end
