# -*- encoding : utf-8 -*-
require 'spec_helper'

describe User do
  context :active do
    it 'should not have password' do
      user = User.new name: 'Lorem', email: 'random@email.com'
      user.password.should be_nil
      user.active?.should be_false
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
end
