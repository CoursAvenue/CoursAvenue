# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CommentNotification do
  context :comment_notification do

    # -------------------------------
    # Never received emails
    # -------------------------------
    context 'never received emails' do
      let!(:comment_notification) { FactoryGirl.create(:comment_notification) }
      describe '#resend_recommendation_stage_1' do
        it 'should be notified' do
          UsersReminder.resend_recommendation_stage_1
          comment_notification.reload.status.should eq 'resend_stage_1'
        end
      end
      describe '#resend_recommendation_stage_2' do
        it 'should not be notified' do
          UsersReminder.resend_recommendation_stage_2
          comment_notification.reload.status.should be_nil
        end
      end
      describe '#resend_recommendation_stage_3' do
        it 'should not be notified' do
          UsersReminder.resend_recommendation_stage_3
          comment_notification.reload.status.should be_nil
        end
      end
    end

    # -------------------------------
    # Has already received 1 email
    # -------------------------------
    context 'has already received one email' do
      let!(:comment_notification_stage_1) { FactoryGirl.create(:comment_notification_stage_1) }
      describe '#resend_recommendation_stage_1' do
        it 'should be notified' do
          UsersReminder.resend_recommendation_stage_1
          comment_notification_stage_1.reload.status.should eq 'resend_stage_1'
        end
      end
      describe '#resend_recommendation_stage_2' do
        context 'right after' do
          it 'should not be notified' do
            UsersReminder.resend_recommendation_stage_2
            comment_notification_stage_1.reload.status.should eq 'resend_stage_1'
          end
        end
        context '4 day after' do
          it 'should not be notified' do
            time_travel_to Date.today + 4.days
            UsersReminder.resend_recommendation_stage_2
            comment_notification_stage_1.reload.status.should eq 'resend_stage_2'
            back_to_the_present
          end
        end
        context '6 day after' do
          it 'should not be notified' do
            UsersReminder.resend_recommendation_stage_2
            comment_notification_stage_1.reload.status.should eq 'resend_stage_1'
          end
        end
      end
      describe '#resend_recommendation_stage_3' do
        it 'should not be notified' do
          UsersReminder.resend_recommendation_stage_3
          comment_notification_stage_1.reload.status.should eq 'resend_stage_1'
        end
      end
    end

    # -------------------------------
    # Has already received 2 emails
    # -------------------------------
    context 'has already received one email' do
      let!(:comment_notification_stage_2) { FactoryGirl.create(:comment_notification_stage_2) }
      describe '#resend_recommendation_stage_1' do
        it 'should be notified' do
          UsersReminder.resend_recommendation_stage_1
          comment_notification_stage_2.reload.status.should eq 'resend_stage_2'
        end
      end
      describe '#resend_recommendation_stage_2' do
        it 'should not be notified' do
          UsersReminder.resend_recommendation_stage_2
          comment_notification_stage_2.reload.status.should eq 'resend_stage_2'
        end
      end
      describe '#resend_recommendation_stage_3' do
        context 'right after' do
          it 'should not be notified' do
            UsersReminder.resend_recommendation_stage_3
            comment_notification_stage_2.reload.status.should eq 'resend_stage_2'
          end
        end
        context '5 day after last email sent' do
          it 'should not be notified' do
            time_travel_to Date.today + 5.days
            UsersReminder.resend_recommendation_stage_3
            comment_notification_stage_2.reload.status.should eq 'resend_stage_3'
            back_to_the_present
          end
        end
      end
    end
  end
end
