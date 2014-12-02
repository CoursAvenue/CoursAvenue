# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Comment::Review do

  context :review do
    context :title do
      it 'removes the first and last quotes if there are in the title' do
        comment = FactoryGirl.build(:comment_review, title: '"Title with quotes"')
        comment.save
        expect(comment.title).to eq "Title with quotes"
      end
    end

    context :structure do
      let(:comment) { FactoryGirl.create(:comment_review) }
      it 'returns the structure' do
        expect(comment.structure).to be comment.commentable
      end
    end

    context 'does not have a user' do
      let(:comment) { FactoryGirl.build(:comment_review) }
      it 'creates a user' do
        comment.user = nil
        comment.save
        expect(comment.user).to_not be_nil
      end
    end

    context :validations do
      let(:comment) { FactoryGirl.create(:comment_review) }
      describe '#doesnt_exist_yet' do
        it 'exists and adds errors' do
          new_comment = FactoryGirl.build(:comment_review, email: comment.email, commentable: comment.commentable)
          expect(new_comment.valid?).to be(false)
          expect(new_comment.errors[:email].length).to eq 1
        end
      end
    end

    context :callbacks do
      let(:comment) { FactoryGirl.build(:comment_review) }
      context :user_passions do
        it 'creates a passion for the user' do
          comment.save
          expect(comment.user.passions).to_not be_empty
        end
      end

      context :user_structure do
        it 'creates a passion for the user' do
          comment.save
          expect(comment.user.structures).to include(comment.structure)
        end
      end

      describe '#create_or_update_user_profile' do
        it "creates a user profile if doesn't exists" do
          structure = comment.structure
          length    = structure.user_profiles.reload.length
          comment.save
          expect(structure.user_profiles.reload.length).to eq (length + 1)
        end

        it 'affects a tag after a comment' do
          comment.save
          expect(comment.structure.user_profiles.last.tags.map(&:name)).to include UserProfile::DEFAULT_TAGS[:comments]
        end
      end

      describe '#downcase_email' do
        it 'transforms the email to have it downcase' do
          comment = Comment::Review.new email: 'LAAL@ALA.COM'
          comment.send(:downcase_email)
          expect(comment.email).to eq 'LAAL@ALA.COM'.downcase
        end
      end

      describe '#remove_quotes_from_title' do
        it 'Removes quotes from title at ends' do
          comment = Comment::Review.new title: '"zadpoj azdjz"'
          comment.send(:remove_quotes_from_title)
          expect(comment.title).not_to include '"'
        end
      end

      describe '#strip_names' do
        it 'Removes quotes from title at ends' do
          comment = Comment::Review.new title: ' title ', author_name: ' author_name ', course_name: ' course_name '
          comment.send(:strip_names)
          expect(comment.title).to eq 'title'
          expect(comment.author_name).to eq 'author_name'
          expect(comment.course_name).to eq 'course_name'
        end
      end
    end

    context 'create a comment from a user that has a comment_notification' do
      let(:comment_notification) { FactoryGirl.create(:comment_notification) }
      it 'creates a comment notification for a user' do
        user     = comment_notification.user
        _comment = FactoryGirl.build(:comment_review, author_name: user.name, email: user.email, commentable: comment_notification.structure, user: user)
        _comment.save
        expect(comment_notification.reload.status).to eq 'completed'
      end
    end
  end
end
