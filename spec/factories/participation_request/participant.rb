FactoryGirl.define do
  factory :participation_request_participant, class: 'ParticipationRequest::Participant' do
    price
    participation_request
    number (1..4).to_a.sample
  end
end
