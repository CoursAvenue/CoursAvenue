# -*- encoding : utf-8 -*-
require 'rails_helper'

describe ParticipationRequest do

  subject { ParticipationRequest.new }
  let(:participation_request)  { FactoryGirl.create(:participation_request) }
  let(:structure)              { FactoryGirl.create(:structure_with_admin) }
  let(:planning)               { FactoryGirl.create(:planning) }
  let(:user)                   { FactoryGirl.create(:user) }

  describe '#create_and_send_message' do
    it 'saves it' do
      request_attributes = {
        course_id:     planning.course.id,
        planning_id:   planning.id,
        date:          Date.tomorrow.to_s,
        structure_id:  structure.id,
        message: { body: 'lala' }
      }
      pr = ParticipationRequest.create_and_send_message(request_attributes, user)
      expect(pr).to be_persisted
    end

  end

  describe '#accepted?' do
    it 'is accepted' do
      subject.state = 'accepted'
      expect(subject.accepted?).to be_truthy
    end
    it 'is not accepted' do
      subject.state = 'canceled'
      expect(subject.accepted?).to be_falsy
    end
  end

  describe '#pending?' do
    it 'is pending' do
      subject.state = 'pending'
      expect(subject.pending?).to be_truthy
    end
    it 'is not pending' do
      subject.state = 'canceled'
      expect(subject.pending?).to be_falsy
    end
  end

  describe '#canceled?' do
    it 'is canceled' do
      subject.state = 'canceled'
      expect(subject.canceled?).to be_truthy
    end
    it 'is not canceled' do
      subject.state = 'pending'
      expect(subject.canceled?).to be_falsy
    end
  end

  describe '#past?' do
    it 'returns true' do
      subject.date = Date.yesterday
      expect(subject.past?).to eq true
    end

    it 'returns false' do
      subject.date = Date.tomorrow
      expect(subject.past?).to eq false
    end
  end

  describe '#accept!', with_mail: true do
    it 'changes the status to accepted' do
      participation_request.accept!('lala', 'User')
      expect(participation_request.accepted?).to be_truthy
    end

    it 'sends a message' do
      expect{ participation_request.accept!('lala', 'User') }.to change {
        participation_request.reload.conversation.messages.length
      }.by(1)
    end
  end

  describe '#modify_date!' do
    it 'changes the status to pending' do
      participation_request.modify_date!('lala', { date: Date.tomorrow.to_s }, 'User')
      expect(participation_request.pending?).to be_truthy
    end

    it 'sends a message' do
      expect{ participation_request.modify_date!('lala', { date: Date.tomorrow.to_s }, 'User') }.to change {
        participation_request.reload.conversation.messages.length
      }.by(1)
    end

    it 'modify the date' do
      participation_request.modify_date!('lala', { date: Date.tomorrow.to_s }, 'User')
      expect(participation_request.date).to eq Date.tomorrow
    end
  end

end
