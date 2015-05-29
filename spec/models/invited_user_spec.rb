# -*- encoding : utf-8 -*-
require 'rails_helper'

describe InvitedUser do

  let(:user)      { FactoryGirl.create(:user) }
  let(:structure) { FactoryGirl.create(:structure) }
  let(:invited_user) { InvitedUser.new(type: 'InvitedUser::Student', referrer_id: user.id, referrer_type: 'User', email: Faker::Internet.email) }

  context '#inform_proposer' do
    it 'updates the registered attribute' do
      invited_user.inform_proposer
      expect(invited_user.registered).to be(true)
    end

    it 'sends an email in queue', with_mail: true do
      expect {
        invited_user.inform_proposer
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context '#send_invitation_stage_1' do
    it 'updates the status' do
      invited_user.send_invitation_stage_1
      expect(invited_user.email_status).to eq 'resend_stage_1'
    end

    it 'sends an email in queue', with_mail: true do
      expect {
        invited_user.send_invitation_stage_1
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context '#send_invitation_stage_2' do
    it 'updates the status' do
      invited_user.send_invitation_stage_2
      expect(invited_user.email_status).to eq 'resend_stage_2'
    end

    it 'sends an email in queue', with_mail: true do
      expect {
        invited_user.send_invitation_stage_2
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context '#referrer' do
    it 'returns a Structure' do
      invited_user = InvitedUser.new referrer_id: user.id, referrer_type: 'User', email: Faker::Internet.email
      expect(invited_user.referrer).to eq user
    end

    it 'returns a User' do
      invited_user = InvitedUser.new referrer_id: structure.id, referrer_type: 'Structure', email: Faker::Internet.email
      expect(invited_user.referrer).to eq structure
    end
  end
end
