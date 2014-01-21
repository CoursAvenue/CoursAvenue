# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Pro::PlanningsController do

  let(:admin)     { FactoryGirl.create(:admin) }
  let(:open_course) { FactoryGirl.create(:open_course) }

  before do
    sign_in admin
  end

  describe :create do
    context :open_course do
      it 'redirects to open courses path' do
        post :create, planning: { course_id: open_course.id}, subdomain: 'pro'
        expect(response).to redirect_to(pro_structure_course_opens_path(open_course.structure))
      end
    end
    # context :lesson do
    #   it 'should redirect to open courses' do
    #     post :create, planning: { course_id: open_course.id}
    #     expect(response).to redirect_to(pro_structure_course_opens_path(open_course.structure))
    #   end
    # end
  end
end
