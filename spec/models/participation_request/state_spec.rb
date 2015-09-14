require 'rails_helper'

RSpec.describe ParticipationRequest::State, type: :model do
  describe '#accept!' do
    it 'changes the state to accepted' do
      prs = FactoryGirl.create(:participation_request_state)
      current_state = prs.state
      expect { prs.accept! }.to change { prs.state }.from(current_state).to('accepted')
    end

    it 'adds an event' do
      prs = FactoryGirl.create(:participation_request_state)
      expect { prs.accept! }.to change { prs.get_events.length }.by(1)
    end
  end

  describe '#cancel!' do
    it 'changes the state to canceled' do
      prs = FactoryGirl.create(:participation_request_state)
      current_state = prs.state
      expect { prs.cancel! }.to change { prs.state }.from(current_state).to('canceled')
    end

    it 'adds an event' do
      prs = FactoryGirl.create(:participation_request_state)
      expect { prs.cancel! }.to change { prs.get_events.length }.by(1)
    end
  end

  describe '#treat!' do
    it 'changes the state to treated' do
      prs = FactoryGirl.create(:participation_request_state)
      current_state = prs.state
      expect { prs.treat! }.to change { prs.state }.from(current_state).to('treated')
    end

    it 'adds an event' do
      prs = FactoryGirl.create(:participation_request_state)
      expect { prs.treat! }.to change { prs.get_events.length }.by(1)
    end
  end

  describe 'accepted?' do
    context 'when accepted' do
      it 'is not true' do
        prs = FactoryGirl.build_stubbed(:participation_request_state)
        expect(prs.accepted?).to be_falsy
      end
    end

    context 'when not accepted' do
      it 'is true' do
        prs = FactoryGirl.build_stubbed(:participation_request_state, :accepted)
        expect(prs.accepted?).to be_truthy
      end
    end
  end

  describe 'canceled?' do
    context 'when canceled' do
      it 'is not true' do
        prs = FactoryGirl.build_stubbed(:participation_request_state)
        expect(prs.canceled?).to be_falsy
      end
    end

    context 'when not canceled' do
      it 'is true' do
        prs = FactoryGirl.build_stubbed(:participation_request_state, :canceled)
        expect(prs.canceled?).to be_truthy
      end
    end
  end

  describe 'treated?' do
    context 'when treated' do
      it 'is not true' do
        prs = FactoryGirl.build_stubbed(:participation_request_state)
        expect(prs.treated?).to be_falsy
      end
    end

    context 'when not treated' do
      it 'is true' do
        prs = FactoryGirl.build_stubbed(:participation_request_state, :treated)
        expect(prs.treated?).to be_truthy
      end
    end
  end

  describe 'pending?' do
    context 'when pending' do
      it 'is not true' do
        prs = FactoryGirl.build_stubbed(:participation_request_state, :accepted)
        expect(prs.pending?).to be_falsy
      end
    end

    context 'when not pending' do
      it 'is true' do
        prs = FactoryGirl.build_stubbed(:participation_request_state)
        expect(prs.pending?).to be_truthy
      end
    end
  end

  describe 'get_events' do
    context 'when there are no events' do
      it do
        prs = FactoryGirl.build_stubbed(:participation_request_state)
        expect(prs.get_events).to be_empty
      end
    end

    context 'when are events' do
      it do
        prs = FactoryGirl.create(:participation_request_state)
        prs.send(:add_event, { state: 'state', date: DateTime.current })
        expect(prs.get_events).to_not be_empty
      end
    end
  end
end
