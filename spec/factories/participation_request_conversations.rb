FactoryGirl.define do
  factory :participation_request_conversation, class: 'ParticipationRequest::Conversation' do
    participation_request
  end
end
