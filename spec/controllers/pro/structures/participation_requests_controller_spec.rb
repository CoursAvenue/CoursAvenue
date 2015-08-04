require 'rails_helper'

describe Pro::Structures::ParticipationRequestsController do
  include Devise::TestHelpers

  let(:structure) { FactoryGirl.create(:structure_with_admin) }
  let(:admin) { structure.main_contact }

  before { sign_in admin }

  describe 'POST #rebook' do
    let(:pr)           { FactoryGirl.create(:participation_request, structure: structure) }
    let!(:valid_params) { build_valid_params(pr) }

    it 'creates a new participation request' do
      expect { post :rebook, valid_params }.to change { ParticipationRequest.count }.by(1)
    end

    it 'redirects to the new participation request page' do
      post :rebook, valid_params
      pr = ParticipationRequest.last
      expect(response).to redirect_to(pro_structure_participation_request_path(pr.structure, pr))
    end
  end

  def build_valid_params(pr)
    {
      id: pr.token,
      structure_id: pr.structure.slug,
      participation_request: {
        course_id: pr.course_id,
        planning_id: pr.planning_id,
        date: I18n.l(5.day.from_now.to_date),
        start_hour: '8',
        start_min: '0',
        message: { body: Faker::Lorem.paragraph(2) },
      },
    }
  end
end
