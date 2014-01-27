# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Pro::Courses::PlanningsController do

  before :all do
    @admin           = FactoryGirl.build(:admin)
    @admin.structure = FactoryGirl.create(:structure_with_place)
    @admin.save
  end

  before :each do
    sign_in @admin
  end


  describe :index do
    context :course do
      let(:course) { FactoryGirl.create(:lesson, structure: @admin.structure) }
      it 'works' do
        planning = FactoryGirl.create(:planning, structure: @admin.structure)
        get :index, course_id: course.id
        expect(response).to be_success
      end
    end
  end

  describe :new do
    context :course do
      let(:course) { FactoryGirl.create(:lesson, structure: @admin.structure) }
      it 'works' do
        get :new, course_id: course.id
        expect(response).to be_success
      end
    end

    context :workshop do
      let(:workshop) { FactoryGirl.create(:workshop, structure: @admin.structure) }
      it 'works' do
        get :new, course_id: workshop.id
        expect(response).to be_success
      end
    end

    context :training do
      let(:training) { FactoryGirl.create(:training, structure: @admin.structure) }
      it 'works' do
        get :new, course_id: training.id
        expect(response).to be_success
      end
    end
  end

  describe :edit do
    let(:course)   { FactoryGirl.create(:lesson, structure: @admin.structure) }
    let(:planning) { FactoryGirl.create(:planning, course: course) }

    it 'works' do
      get :edit, course_id: course.id, id: planning.id
      expect(response).to be_success
    end
  end

  describe :create do
    context :open_course do
      let(:open_course) { FactoryGirl.create(:open_course, structure: @admin.structure) }
      it 'redirects to open courses path' do
        post :create, course_id: open_course.id, planning: {  }
        expect(response).to redirect_to(pro_structure_course_opens_path(@admin.structure))
      end
    end

    context :workshop do
      let(:workshop)             { FactoryGirl.create(:workshop, structure: @admin.structure) }
      it 'redirects to open courses path' do
        place_id = @admin.structure.places.first.id
        post :create, course_id: workshop.id, planning: FactoryGirl.attributes_for(:planning).merge(place_id: place_id)
        expect(response).to redirect_to(pro_course_plannings_path(workshop))
      end
    end

    context :lesson do
      let(:lesson) { FactoryGirl.create(:lesson, structure: @admin.structure) }
      it 'redirects to open courses path' do
        place_id = @admin.structure.places.first.id
        post :create, course_id: lesson.id, planning: FactoryGirl.attributes_for(:planning).merge(place_id: place_id)
        expect(response).to redirect_to(pro_course_plannings_path(lesson))
      end
    end
    context :training do
      let(:training) { FactoryGirl.create(:training, structure: @admin.structure) }
      it 'redirects to open courses path' do
        place_id = @admin.structure.places.first.id
        post :create, course_id: training.id, planning: FactoryGirl.attributes_for(:planning).merge(place_id: place_id)
        expect(response).to redirect_to(pro_course_plannings_path(training))
      end
    end
  end
end
