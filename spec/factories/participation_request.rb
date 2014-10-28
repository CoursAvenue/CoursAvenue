#-*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :participation_request do
    user
    conversation
    structure         { FactoryGirl.create(:structure_with_admin) }
    course
    planning
    state             'pending'
    date              3.days.from_now
    start_time        Time.now
    end_time          Time.now + 3.hours
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

  end
end
