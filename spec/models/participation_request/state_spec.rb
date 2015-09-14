require 'rails_helper'

RSpec.describe ParticipationRequest::State, type: :model do
  describe '#accept' do
    it 'changes the state to accepted' do
      prs = FactoryGirl.create(:participation_request_state)
      expect { prs.accept! }.to change { prs.state }.from('pending').to('accepted')
    end

  end
end
