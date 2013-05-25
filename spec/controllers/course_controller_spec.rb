# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CoursesController do

  subject {course}
  let(:course) { FactoryGirl.create(:course) }

  describe '#show' do
    it { response.status.should eq 200 }
    context 'slug changes' do
      it 'should respond with 301' do
        initial_slug = course.slug
        course.name += ' some extension'
        course.save
        get :show, id: initial_slug
        # Check, why 302 and not 301
        response.status.should eq 302
      end
    end
  end
end
