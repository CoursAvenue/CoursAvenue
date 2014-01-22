# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Structures::CoursesController do

  let(:course) { FactoryGirl.create(:course) }
  subject {course}

  describe '#show' do
    before do
      Rails.application.config.consider_all_requests_local = false
      load "application_controller.rb"
    end

    after do
      Rails.application.config.consider_all_requests_local = true
      load "application_controller.rb"
    end

    subject { response.status }

    context 'when course is not active' do
      it 'redirects to home page' do
        course.update_column :active, false
        get :show, id: course.id, structure_id: course.structure_id
        should eq 301
      end
    end

    context 'when resource is found' do
      it { should eq 200 }
    end

    context 'when resource is not found' do
      it 'redirects to home page' do
        get :show, id: 'something_impossible', structure_id: 1
        response.status.should eq 301
        response.should redirect_to root_path
      end
    end
  end

end
