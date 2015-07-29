require 'rails_helper'

describe Structures::CommunityController, community: true do
  let(:structure) { FactoryGirl.create(:structure) }
  let!(:community) { FactoryGirl.create(:community, structure: structure) }

  describe 'GET #show' do
    context 'with json format' do
      it 'renders the community as json' do
        get :show, structure_id: structure.slug, format: :json
        expect(response_body['id']).to eq(community.id)
      end
    end

    context 'with html format' do
      it 'redirects to the structure page' do
        get :show, structure_id: structure.slug
        expect(response).to redirect_to(structure_path(structure))
      end
    end
  end

  def response_body
    JSON.parse(response)
  end
end
