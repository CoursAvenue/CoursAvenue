# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersReminder do
  let(:structure) { FactoryGirl.create(:structure) }

  context 'user does not exist' do
    it 'creates a user' do
      user_count = User.count
      UsersReminder.send_recommendation(structure, 'fake text', Forgery(:internet).email_address)
      User.count.should eq user_count + 1
    end
    it 'creates a comment_notification' do
      user_email = Forgery(:internet).email_address
      UsersReminder.send_recommendation(structure, 'fake text', user_email)
      user = User.where{email == user_email}.first

      user.comment_notifications.should_not be_empty
    end
  end

  context 'user exists' do
    let(:user)      { FactoryGirl.create(:user) }
    it 'creates a comment_notification' do
      UsersReminder.send_recommendation(structure, 'fake text', user.email)
      user.comment_notifications.should_not be_empty
    end
  end

end

