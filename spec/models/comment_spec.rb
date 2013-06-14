# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Comment do
  let(:course_comment)    { FactoryGirl.create(:course_comment) }
  let(:structure_comment) { FactoryGirl.create(:structure_comment) }
  let(:course)            { FactoryGirl.create(:course) }
  let(:structure) { course.structure }

  context :course do

    it 'has the course title' do
      comment = course.comments.create FactoryGirl.attributes_for(:comment)
      comment.title.should == course.name
    end
  end

  context :structure do
    it 'returns the structure' do
      course_comment.structure.should be    course_comment.commentable.structure
      structure_comment.structure.should be structure_comment.commentable
    end
  end
end
