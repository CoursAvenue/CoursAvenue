FactoryGirl.define do
  factory :participation_request_state, :class => 'ParticipationRequest::State' do

    state "pending"
    # events []
    accepted_at nil
    treated_at nil
    canceled_at nil

    trait :accepted do
      state 'accepted'
      accepted_at 1.hour.ago
    end

    trait :canceled do
      state 'canceled'
      canceled_at 1.hour.ago
    end

    trait :treated do
      state 'treated'
      treated_at 1.hour.ago
    end
  end
end
