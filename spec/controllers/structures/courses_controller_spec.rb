# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Structures::CoursesController do

  subject {course}
  let(:course) { FactoryGirl.create(:course) }

  describe '#show' do
    subject { response.status }

    it 'returns 200' do
      get :show, structure_id: course.structure.id, id: course.id
      expect(response.status).to eq(200)
    end
  end

end
