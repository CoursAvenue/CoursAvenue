require 'rails_helper'
require 'rake'

CoursAvenue::Application.load_tasks

context "scheduler:participation_requests", with_mail: true do

  context 'For Admins' do

    describe "remind_admin_for_participation_requests_1" do
      context 'created the previous day' do

        let(:pending_pr) { FactoryGirl.create(:participation_request, :pending_state) }

        before do
          pending_pr.created_at = Date.yesterday
          pending_pr.save
        end

        it "sends an email for pending request the day after" do
          task_name = 'scheduler:participation_requests:remind_admin_for_participation_requests_1'
          expect do
            Rake::Task[task_name].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'not created the previous day' do
        let(:pending_pr)   { FactoryGirl.create(:participation_request, :pending_state) }
        let(:pending_pr_2) { FactoryGirl.create(:participation_request, :pending_state) }

        before do
          pending_pr.created_at   = Date.today
          pending_pr.save

          pending_pr_2.created_at = 2.days.ago
          pending_pr_2.save
        end

        it "does not send an email for pending request" do
          task_name = 'scheduler:participation_requests:remind_admin_for_participation_requests_1'
          expect do
            Rake::Task[task_name].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(0)
        end
      end
    end

    describe "remind_admin_for_participation_requests_2" do

      context 'created two days before' do
        let(:pending_pr) { FactoryGirl.create(:participation_request, :pending_state) }

        before do
          pending_pr.created_at = 2.days.ago
          pending_pr.save
        end

        it "sends an email for pending request" do
          task_name = 'scheduler:participation_requests:remind_admin_for_participation_requests_2'
          expect do
            Rake::Task[task_name].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'not created two days before' do
        let(:pending_pr)   { FactoryGirl.create(:participation_request, :pending_state) }
        let(:pending_pr_2) { FactoryGirl.create(:participation_request, :pending_state) }

        before do
          pending_pr.created_at   = Date.today
          pending_pr.save

          pending_pr_2.created_at = 1.day.ago
          pending_pr_2.save
        end

        it "does not send an email for pending request" do
          task_name = 'scheduler:participation_requests:remind_admin_for_participation_requests_2'
          expect do
            Rake::Task[task_name].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(0)
        end
      end
    end

    describe 'recap_for_teacher' do
      context 'for an accepted request' do
        it "sends a recap email for teachers day before a request" do
          accepted_pr = FactoryGirl.create(:participation_request, date: Date.tomorrow)
          accepted_pr.state.accept!

          accepted_pr2 = FactoryGirl.create(:participation_request, date: 2.days.from_now)
          accepted_pr2.state.accept!

          expect do
            Rake::Task['scheduler:participation_requests:recap_for_teacher'].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'for a pending request' do
        it "does not send an email for pending request" do
          accepted_pr = FactoryGirl.create(:participation_request, :accepted_state, date: 2.days.from_now)
          pending_pr = FactoryGirl.create(:participation_request, :pending_state, date: Date.tomorrow)
          expect do
            Rake::Task['scheduler:participation_requests:recap_for_teacher'].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(0)
        end
      end
    end

    #   describe 'how_was_the_student' do
    #     it 'sends an email day after the trial' do
    #       accepted_pr.date   = Date.yesterday; accepted_pr.save
    #       accepted_pr_2.date = 2.days.from_now; accepted_pr_2.save
    #       pending_pr.date    = Date.yesterday; pending_pr.save
    #       expect do
    #         Rake::Task['scheduler:participation_requests:how_was_the_student'].invoke
    #       end.to change { ActionMailer::Base.deliveries.count }.by(1)
    #     end
    #   end
  end

  context 'For Users' do
    describe "remind_user_for_participation_requests_1" do
      context 'created the previous day' do
        let(:pending_pr) { FactoryGirl.create(:participation_request, :last_modified_by_structure) }

        before do
          pending_pr.update_column :updated_at, Date.yesterday
        end

        it "sends an email for pending request the day after" do
          task_name = 'scheduler:participation_requests:remind_user_for_participation_requests_1'
          expect do
            Rake::Task[task_name].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'not created the previous day' do
        let(:pending_pr)   { FactoryGirl.build_stubbed(:participation_request, :last_modified_by_structure) }
        let(:pending_pr_2) { FactoryGirl.build_stubbed(:participation_request, :last_modified_by_structure) }

        it "does not send an email for pending request" do
          pending_pr.updated_at = Date.today
          pending_pr_2.updated_at = 2.days.ago
          task_name = 'scheduler:participation_requests:remind_user_for_participation_requests_1'
          expect do
            Rake::Task[task_name].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(0)
        end
      end
    end

    describe "remind_user_for_participation_requests_2" do
      context 'created two days before' do
        let(:pending_pr) { FactoryGirl.create(:participation_request, :last_modified_by_structure) }

        before do
          pending_pr.update_column :updated_at, 2.days.ago
        end

        it "sends an email for pending request" do
          task_name = 'scheduler:participation_requests:remind_user_for_participation_requests_2'
          expect do
            Rake::Task[task_name].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'not created two days before' do
        let(:pending_pr)   { FactoryGirl.create(:participation_request, :last_modified_by_structure) }
        let(:pending_pr_2) { FactoryGirl.create(:participation_request, :last_modified_by_structure) }

        before do
          pending_pr.update_column :updated_at, Date.today
          pending_pr_2.update_column :updated_at, 1.day.ago
        end

        it "does not send an email for pending request" do
          task_name = 'scheduler:participation_requests:remind_user_for_participation_requests_2'
          expect do
            Rake::Task[task_name].invoke
          end.to change { ActionMailer::Base.deliveries.count }.by(0)
        end
      end
    end

    describe 'how_was_the_trial' do
      let(:accepted_pr)   { FactoryGirl.create(:participation_request, :accepted_state) }
      let(:accepted_pr_2) { FactoryGirl.create(:participation_request, :accepted_state) }
      let(:pending_pr)    { FactoryGirl.create(:participation_request, :last_modified_by_structure) }

      before do
        accepted_pr.date   = Date.yesterday
        accepted_pr.save

        accepted_pr_2.date = 2.days.from_now
        accepted_pr_2.save

        pending_pr.date    = Date.yesterday
        pending_pr.save
      end

      it 'sends an email day after the trial' do
        expect do
          Rake::Task['scheduler:participation_requests:how_was_the_trial'].invoke
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe 'how_was_the_trial_stage_1' do
      let(:accepted_pr)   { FactoryGirl.create(:participation_request, :accepted_state) }
      let(:accepted_pr_2) { FactoryGirl.create(:participation_request, :accepted_state) }
      let(:pending_pr)    { FactoryGirl.create(:participation_request, :last_modified_by_structure) }

      before do
        accepted_pr.date = 5.days.ago
        accepted_pr.save

        accepted_pr_2.date = 2.days.ago
        accepted_pr_2.save

        pending_pr.date = Date.yesterday
        pending_pr.save
      end

      it 'sends an email 5 days after the trial ONLY if the user did not left a comment' do
        expect do
          Rake::Task['scheduler:participation_requests:how_was_the_trial_stage_1'].invoke
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
