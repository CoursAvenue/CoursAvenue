# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Comment do

  context :structure do
    let(:comment) { FactoryGirl.create(:comment) }
    it 'returns the structure' do
      comment.structure.should be comment.commentable
    end
  end

  context 'does not have a user' do
    let(:comment) { FactoryGirl.build(:comment) }
    it 'creates a user' do
      comment.user = nil
      comment.save
      comment.user.should_not be_nil
    end
  end

  let(:comment_notification) { FactoryGirl.create(:comment_notification) }
  context 'create a comment from a user that has a comment_notification' do
    it 'creates a comment notification for a user' do
      user     = comment_notification.user
      _comment = Comment.new(author_name: user.name, email: user.email, commentable: comment_notification.structure, user: user, content: 'lorem', course_name: 'lala')
      _comment.save
      comment_notification.reload.status.should eq 'completed'
    end
  end

end
