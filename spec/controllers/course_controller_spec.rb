# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Structure::CoursesController do

  subject {course}
  let(:course) { FactoryGirl.create(:course) }

  context 'slug changes' do
    it 'should respond with 301' do
      initial_slug = course.slug
      get :show, id: initial_slug
      response.status.should eq 200
      course.slug += '-some-extension'
      course.save
      get :show, id: initial_slug
      response.status.should eq 301
    end
  end

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
       get :show, id: course.id
       should eq 301
     end
    end

    context 'when resource is found' do
      it { should eq 200 }
    end

    context 'when resource is not found' do
      it 'redirects to home page' do
        get :show, id: 'something_impossible'
        response.status.should eq 301
        response.should redirect_to root_path
      end
    end
  end

  describe '#index' do
    before(:all) do
      Course.delete_all
      # Sunspot.remove_all!(Course)
      @course = FactoryGirl.create(:course)
      @place  = @course.place
      @course.index!
    end
    before(:each) do
      get :index, lat: @place.latitude, lng: @place.longitude
    end
    subject { assigns('courses') }
    it { should have(1).item }
  end
end
