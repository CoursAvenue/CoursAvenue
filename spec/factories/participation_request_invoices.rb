FactoryGirl.define do
  factory :participation_request_invoice, class: 'ParticipationRequest::Invoice' do
    participation_request
  end
end
