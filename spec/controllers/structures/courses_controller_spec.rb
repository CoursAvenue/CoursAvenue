# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Structures::CoursesController do
  let(:structure) { FactoryGirl.create(:structure) }

  describe 'GET #index' do
    context 'with json format' do

      before do
        5.times do
          course = FactoryGirl.create(:course, structure: structure)
          planning = FactoryGirl.create(:planning, course: course)
          course.plannings.reload
        end
        structure.courses.reload
      end

      it 'renders the structure courses' do
        get :index, structure_id: structure.slug, format: :json
        course_ids = response_body['courses'].map { |c| c['id'] }
        expect(course_ids).to match_array(structure.courses.map(&:id))
      end
    end
  end

  def response_body
    JSON.parse(response.body)
  end
end
