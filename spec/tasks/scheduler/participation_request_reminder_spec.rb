require 'rails_helper'
require 'rake'

CoursAvenue::Application.load_tasks

context "scheduler:participation_requests" do

  context 'For Admins' do
    let (:accepted_participation_request)   { FactoryGirl.create(:participation_request, :accepted_state) }
    let (:accepted_participation_request_2) { FactoryGirl.create(:participation_request, :accepted_state) }
    let (:pending_participation_request)    { FactoryGirl.create(:participation_request, :pending_state) }
    let (:pending_participation_request_2)  { FactoryGirl.create(:participation_request, :pending_state) }

    describe "remind_admin_for_participation_requests_1" do
      it "sends an email for pending request the day after" do
        pending_participation_request.created_at = Date.yesterday
        pending_participation_request.save
        expect {
          Rake::Task['scheduler:participation_requests:remind_admin_for_participation_requests_1'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "does not send an email for pending request" do
        pending_participation_request.created_at   = Date.today; pending_participation_request.save
        pending_participation_request_2.created_at = 2.days.ago; pending_participation_request_2.save
        expect {
          Rake::Task['scheduler:participation_requests:remind_admin_for_participation_requests_1'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

    describe "remind_admin_for_participation_requests_2" do
      it "sends an email for pending request two days after" do
        pending_participation_request.created_at = 2.days.ago
        pending_participation_request.save
        expect {
          Rake::Task['scheduler:participation_requests:remind_admin_for_participation_requests_2'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "does not send an email for pending request" do
        pending_participation_request.created_at   = Date.today; pending_participation_request.save
        pending_participation_request_2.created_at = 1.day.ago; pending_participation_request_2.save
        expect {
          Rake::Task['scheduler:participation_requests:remind_admin_for_participation_requests_2'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

    describe 'recap_for_teacher' do
      it "sends a recap email for teachers day before a request" do
        accepted_participation_request.date = Date.tomorrow
        accepted_participation_request.save
        expect {
          Rake::Task['scheduler:participation_requests:recap_for_teacher'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "does not send an email for pending request" do
        accepted_participation_request.date = 2.days.from_now
        accepted_participation_request.save
        pending_participation_request_2.date = Date.tomorrow
        pending_participation_request_2.save
        expect {
          Rake::Task['scheduler:participation_requests:recap_for_teacher'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

  #   describe 'how_was_the_student' do
  #     it 'sends an email day after the trial' do
  #       accepted_participation_request.date   = Date.yesterday; accepted_participation_request.save
  #       accepted_participation_request_2.date = 2.days.from_now; accepted_participation_request_2.save
  #       pending_participation_request.date    = Date.yesterday; pending_participation_request.save
  #       expect {
  #         Rake::Task['scheduler:participation_requests:how_was_the_student'].invoke
  #       }.to change { ActionMailer::Base.deliveries.count }.by(1)
  #     end
  #   end
  end

  context 'For Users' do
    let (:pending_participation_request)    { FactoryGirl.create(:participation_request, :last_modified_by_structure) }
    let (:pending_participation_request_2)  { FactoryGirl.create(:participation_request, :last_modified_by_structure) }
    let (:accepted_participation_request)   { FactoryGirl.create(:participation_request, :accepted_state) }
    let (:accepted_participation_request_2) { FactoryGirl.create(:participation_request, :accepted_state) }

    describe "remind_user_for_participation_requests_1" do
      it "sends an email for pending request the day after" do
        pending_participation_request.update_column :updated_at, Date.yesterday
        expect {
          Rake::Task['scheduler:participation_requests:remind_user_for_participation_requests_1'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "does not send an email for pending request" do
        pending_participation_request.update_column :updated_at, Date.today
        pending_participation_request_2.update_column :updated_at, 2.days.ago
        expect {
          Rake::Task['scheduler:participation_requests:remind_user_for_participation_requests_1'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

    describe "remind_user_for_participation_requests_2" do
      it "sends an email for pending request two days after" do
        pending_participation_request.update_column :updated_at, 2.days.ago
        expect {
          Rake::Task['scheduler:participation_requests:remind_user_for_participation_requests_2'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "does not send an email for pending request" do
        pending_participation_request.update_column :updated_at, Date.today
        pending_participation_request_2.update_column :updated_at, 1.day.ago
        expect {
          Rake::Task['scheduler:participation_requests:remind_user_for_participation_requests_2'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

    describe 'how_was_the_trial' do
      it 'sends an email day after the trial' do
        accepted_participation_request.date   = Date.yesterday; accepted_participation_request.save
        accepted_participation_request_2.date = 2.days.from_now; accepted_participation_request_2.save
        pending_participation_request.date    = Date.yesterday; pending_participation_request.save
        expect {
          Rake::Task['scheduler:participation_requests:how_was_the_trial'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe 'how_was_the_trial_stage_1' do
      it 'sends an email 5 days after the trial ONLY if the user did not left a comment' do
        accepted_participation_request.date   = 5.days.ago; accepted_participation_request.save
        accepted_participation_request_2.date = 2.days.ago; accepted_participation_request_2.save
        pending_participation_request.date    = Date.yesterday; pending_participation_request.save
        expect {
          Rake::Task['scheduler:participation_requests:how_was_the_trial_stage_1'].invoke
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

end
