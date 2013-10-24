# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CommentsController do

  describe '#create' do
    let(:structure) { FactoryGirl.create(:structure_with_admin) }

    context 'I add a private message' do
      it 'creates a user' do
        post :create, comment: {
                        commentable_type: 'Structure',
                        commentable_id: structure.id,
                        author_name: 'Author name',
                        course_name: 'Course name',
                        content: 'lorem',
                        email: 'random@test.com'
                      }
        response.should be_redirect
        assigns(:comment).should be_persisted

      end
      it 'sends a private message' do
        structure.main_contact.messages.should be_empty
        post :create, comment: {
                        commentable_type: 'Structure',
                        commentable_id: structure.id,
                        author_name: 'Author name',
                        course_name: 'Course name',
                        content: 'lorem',
                        email: 'random@test.com'
                      },
                      private_message: 'lorem'
        response.should be_redirect
        assigns(:conversation).should be_persisted
      end
    end
  end

end
