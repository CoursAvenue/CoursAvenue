# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Structures::CoursesController do

  describe :show do
    let(:course) { FactoryGirl.create(:course) }
    it 'returns 200' do
      get :show, structure_id: course.structure.id, id: course.id
      expect(response.status).to eq(200)
    end
  end
end
