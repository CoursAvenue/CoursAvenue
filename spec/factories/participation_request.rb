#-*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :participation_request do
    user
    structure         { FactoryGirl.create(:structure_with_admin) }
    course
    planning
    state             'pending'
    date              { 3.days.from_now }
    start_time        { Time.now }
    end_time          { Time.now + 3.hours }
    last_modified_by 'User'

    trait :last_modified_by_structure do
      last_modified_by 'Structure'
    end

    trait :accepted_state do
      state 'accepted'
    end

    trait :pending_state do
      state 'pending'
    end

    trait :with_participants do
      after(:build) do |pr|
        3.times do
          pr.participants << FactoryGirl.create(:participation_request_participant, participation_request: pr)
        end
      end
    end

    after(:build) do |participation_request|
      participation_request.conversation = FactoryGirl.create(:conversation_with_messages)
    end
  end
end
