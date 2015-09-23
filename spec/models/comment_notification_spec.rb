# -*- encoding : utf-8 -*-
require 'rails_helper'

describe CommentNotification do
  context 'validations' do
    it 'has an error on structure if notification_for is empty' do
      comment_notification = CommentNotification.new
      expect(comment_notification.valid?).to be(false)
      expect(comment_notification.errors[:structure].length).to eq 1
    end
    it 'has no error on structure if notification_for is filled' do
      comment_notification = CommentNotification.new notification_for: 'lala'
      expect(comment_notification.valid?).to be(false)
      expect(comment_notification.errors.messages[:structure]).to be_nil
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
        expect(comment_notification_stage_1.reload.status).to eq 'resend_stage_1'
      end
    end
    describe '#resend_recommendation_stage_2' do
      context 'right after' do
        it 'should not be notified' do
          UsersReminder.resend_recommendation_stage_2
          expect(comment_notification_stage_1.reload.status).to eq 'resend_stage_1'
        end
      end
      context '4 day after' do
        it 'should not be notified' do
          time_travel_to Date.today + 4.days
          UsersReminder.resend_recommendation_stage_2
          expect(comment_notification_stage_1.reload.status).to eq 'resend_stage_1'
          back_to_the_present
        end
      end
      context '6 day after' do
        it 'should not be notified' do
          UsersReminder.resend_recommendation_stage_2
          expect(comment_notification_stage_1.reload.status).to eq 'resend_stage_1'
        end
      end
    end
    describe '#resend_recommendation_stage_3' do
      it 'should not be notified' do
        UsersReminder.resend_recommendation_stage_3
        expect(comment_notification_stage_1.reload.status).to eq 'resend_stage_1'
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
        expect(comment_notification_stage_2.reload.status).to eq 'resend_stage_2'
      end
    end
    describe '#resend_recommendation_stage_2' do
      it 'should not be notified' do
        UsersReminder.resend_recommendation_stage_2
        expect(comment_notification_stage_2.reload.status).to eq 'resend_stage_2'
      end
    end
    describe '#resend_recommendation_stage_3' do
      context 'right after' do
        it 'should not be notified' do
          UsersReminder.resend_recommendation_stage_3
          expect(comment_notification_stage_2.reload.status).to eq 'resend_stage_2'
        end
      end
      context '5 day after last email sent' do
        it 'should not be notified' do
          time_travel_to Date.today + 5.days
          UsersReminder.resend_recommendation_stage_3
          expect(comment_notification_stage_2.reload.status).to eq 'resend_stage_3'
          back_to_the_present
        end
      end
    end
  end

  describe '.create_from_email' do
    context 'without an email' do
      it { expect(CommentNotification.create_from_email(nil, nil, nil)).to be_nil }
    end

    context 'the user does not exists' do
      it 'creates a new User' do
        email = Faker::Internet.email
        structure = FactoryGirl.build_stubbed(:structure)
        text = Faker::Lorem.paragraph
        expect { CommentNotification.create_from_email(email, structure, text) }.
          to change { User.count }.by(1)
      end
    end

    context 'the user already exists' do
      it 'creates a new User' do
        email = FactoryGirl.create(:user).email
        structure = FactoryGirl.build_stubbed(:structure)
        text = Faker::Lorem.paragraph
        expect { CommentNotification.create_from_email(email, structure, text) }.
          to_not change { User.count }
      end
    end

    it 'creates a new CommentNotification' do
      email = Faker::Internet.email
      structure = FactoryGirl.build_stubbed(:structure)
      text = Faker::Lorem.paragraph
      expect { CommentNotification.create_from_email(email, structure, text) }.
        to change { CommentNotification.count }.by(1)
    end

    it 'sends a recomendation email', with_mail: true do
      email = Faker::Internet.email
      structure = FactoryGirl.build_stubbed(:structure)
      text = Faker::Lorem.paragraph
      expect { CommentNotification.create_from_email(email, structure, text) }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
