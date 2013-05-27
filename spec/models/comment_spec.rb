# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Comment do
  let(:course) { FactoryGirl.create(:course) }
  let(:structure) { course.structure }

  context :course do

    it 'has the course title' do
      comment = course.comments.create FactoryGirl.attributes_for(:course_comment)
      comment.title.should == course.name
    end
  end

  context :structure do
    # before do
    #   comment = course.comments.create FactoryGirl.attributes_for(:course_comment)
    #   comment.title.should == course.name
    #   comment = structure.comments.create FactoryGirl.attributes_for(:structure_comment)
    #   comment.title.should == structure.name
    # end

    # it 'aggregates structure and course ratings' do
    #   total_rating = structure.comments.map(&:rating).reduce(:+)
    #   total_rating + structure.courses.each{ |course| course.comments.map(&:rating).reduce(:+) }.reduce()
    #   structure.rating.should ==
    # end
  end
end
