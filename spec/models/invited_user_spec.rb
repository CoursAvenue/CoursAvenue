# -*- encoding : utf-8 -*-
require 'spec_helper'

describe InvitedUser do

  let(:user)      { FactoryGirl.create(:user) }
  let(:structure) { FactoryGirl.create(:structure) }
  let(:invited_user) { InvitedUser.new(type: 'InvitedUser::Student', referrer_id: user.id, referrer_type: 'User', email: Faker::Internet.email) }

  context '#inform_proposer' do
    it 'updates the registered attribute' do
      invited_user.inform_proposer
      expect(invited_user.registered).to be_true
    end
    it 'sends an email in queue' do
      previous_job_count = Delayed::Job.count
      invited_user.inform_proposer
      expect(Delayed::Job.count).to eq previous_job_count + 1
    end
  end

  context '#send_invitation_stage_1' do
    it 'updates the status' do
      invited_user.send_invitation_stage_1
      expect(invited_user.email_status).to eq 'resend_stage_1'
    end

    it 'sends an email in queue' do
      previous_job_count = Delayed::Job.count
      invited_user.send_invitation_stage_1
      expect(Delayed::Job.count).to eq previous_job_count + 1
    end
  end

  context '#send_invitation_stage_2' do
    it 'updates the status' do
      invited_user.send_invitation_stage_2
      expect(invited_user.email_status).to eq 'resend_stage_2'
    end

    it 'sends an email in queue' do
      previous_job_count = Delayed::Job.count
      invited_user.send_invitation_stage_2
      expect(Delayed::Job.count).to eq previous_job_count + 1
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
