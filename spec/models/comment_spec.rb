# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Comment do

  context :title do
    it 'removes the first and last quotes if there are in the title' do
      comment = FactoryGirl.build(:comment, title: '"Title with quotes"')
      comment.save
      comment.title.should eq "Title with quotes"
    end
  end

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

  context :callbacks do
    let(:comment) { FactoryGirl.build(:comment) }
    context :user_passions do
      it 'creates a passion for the user' do
        comment.save
        comment.user.passions.should_not be_empty
      end
    end

    context :user_structure do
      it 'creates a passion for the user' do
        comment.save
        comment.user.structures.should include comment.structure
      end
    end

    describe '#create_or_update_user_profile' do
      it "creates a user profile if doesn't exists" do
        length = comment.structure.user_profiles.length
        comment.save
        expect(comment.structure.user_profiles.length).to eq (length + 1)
      end

      it 'affects a tag after a comment' do
        comment.save
        expect(comment.structure.user_profiles.last.tags.map(&:name)).to include UserProfile::DEFAULT_TAGS[:comments]
      end
    end
  end

  let(:comment_notification) { FactoryGirl.create(:comment_notification) }
  context 'create a comment from a user that has a comment_notification' do
    it 'creates a comment notification for a user' do
      user     = comment_notification.user
      _comment = FactoryGirl.build(:comment, author_name: user.name, email: user.email, commentable: comment_notification.structure, user: user)
      _comment.save
      comment_notification.reload.status.should eq 'completed'
    end
  end

end
