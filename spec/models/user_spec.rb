# -*- encoding : utf-8 -*-
require 'spec_helper'

describe User do
  context :active do
    it 'should not have password' do
      user = User.new first_name: 'Lorem', last_name: 'last_name', email: 'random@email.com'
      user.password.should be_nil
      user.active?.should be_false
    end
  end

  describe '#participate_to?' do
    let (:participation) { FactoryGirl.create(:participation) }

    it 'does not' do
      expect(subject.participate_to?(Planning.new)).to be_false
    end

    it 'participates' do
      expect(participation.user.participate_to?(participation.planning)).to be_true
    end

    it 'has canceled his participations' do
      participation.update_column :canceled_at, Time.now
      expect(participation.user.participate_to?(participation.planning)).to be_false
    end
  end

  describe '#merge' do
    before do
      User.delete_all
    end

    let(:new_user) { FactoryGirl.create(:user) }
    let(:old_user) { FactoryGirl.create(:user) }

    it 'deletes the old user' do
      new_user.merge(old_user)
      old_user.persisted?.should be_false
    end

    it 'merges the comment_notifications' do
      comment_notification         = FactoryGirl.build(:comment_notification, user: old_user)
      old_user.comment_notifications << comment_notification
      new_user.merge(old_user)
      new_user.comment_notifications.should include comment_notification
    end

    it 'merges the comments' do
      comment         = FactoryGirl.create(:comment)
      old_user.comments << comment
      new_user.merge(old_user)
      new_user.comments.should include comment
    end

    it 'merges the messages' do
      message         = FactoryGirl.build(:message, sender: old_user)
      old_user.messages << message
      new_user.merge(old_user)
      new_user.messages.should include message
    end
  end
  describe '#participate_to?' do
    let(:user) { FactoryGirl.create(:user) }
    let(:planning) { FactoryGirl.create(:planning) }

    it 'returns true' do
      user.participations.create(planning: planning)
      expect(user.participate_to?(planning)).to be_true
    end

    it 'returns false' do
      expect(user.participate_to?(planning)).to be_false
    end
  end

  # describe '#update_email_status' do
  #   let(:user) { FactoryGirl.create(:user) }

  #   it 'is passions_incomplete' do
  #     user.update_email_status
  #     expect(user.email_status).to eq 'passions_incomplete'
  #   end
  # end
end
