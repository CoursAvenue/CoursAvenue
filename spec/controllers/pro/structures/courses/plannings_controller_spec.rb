# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Pro::Structures::Courses::PlanningsController do
  include Devise::TestHelpers

  before :all do
    @admin           = FactoryGirl.build(:admin)
    @admin.structure = FactoryGirl.create(:structure_with_place)
    @admin.save
  end

  before :each do
    sign_in @admin
  end


  describe 'index' do
    context 'course' do
      let(:course) { FactoryGirl.create(:lesson, structure: @admin.structure) }
      it 'works' do
        planning = FactoryGirl.create(:planning, structure: @admin.structure)
        get :index, course_id: course.id, structure_id: @admin.structure.slug
        expect(response).to be_success
      end
    end
  end

  describe 'new' do
    context 'course' do
      let(:course) { FactoryGirl.create(:lesson, structure: @admin.structure) }
      it 'works' do
        get :new, course_id: course.id, structure_id: @admin.structure.slug
        expect(response).to be_success
      end
    end

    context 'training' do
      let(:training) { FactoryGirl.create(:training, structure: @admin.structure) }
      it 'works' do
        get :new, course_id: training.id, structure_id: @admin.structure.slug
        expect(response).to be_success
      end
    end
  end

  describe 'edit' do
    let(:course)   { FactoryGirl.create(:lesson, structure: @admin.structure) }
    let(:planning) { FactoryGirl.create(:planning, course: course) }

    it 'works' do
      xhr :get, :edit, course_id: course.id, id: planning.id, structure_id: @admin.structure.slug
      expect(response).to be_success
    end
  end

  describe 'create' do
    context 'lesson' do
      let(:lesson) { FactoryGirl.create(:lesson, structure: @admin.structure) }
      it 'redirects to open courses path' do
        place_id = @admin.structure.places.first.id
        post :create, course_id: lesson.id, planning: FactoryGirl.attributes_for(:planning).merge(place_id: place_id), structure_id: @admin.structure.slug, format: :js
        expect(response).to be_success
      end
    end
    context 'training' do
      let(:training) { FactoryGirl.create(:training, structure: @admin.structure) }
      it 'redirects to open courses path' do
        place_id = @admin.structure.places.first.id
        post :create, course_id: training.id, planning: FactoryGirl.attributes_for(:planning).merge(place_id: place_id), structure_id: @admin.structure.slug, format: :js
        expect(response).to be_success
      end
    end
  end
end
