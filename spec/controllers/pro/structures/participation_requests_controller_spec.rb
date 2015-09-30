require 'rails_helper'

describe Pro::Structures::ParticipationRequestsController do
  include Devise::TestHelpers

  let(:structure) { FactoryGirl.create(:structure_with_admin) }
  let(:admin) { structure.admin }

  it { should use_before_action(:load_structure) }

  before { sign_in admin }

  describe 'GET #index, GET #upcoming, GET #past' do
    [:index, :upcoming, :past].each do |route|
      it 'renders the index template' do
        get route, structure_id: structure.slug
        expect(response).to render_template(route.to_s)
      end
    end
  end

end
