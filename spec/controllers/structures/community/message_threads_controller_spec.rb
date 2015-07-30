require 'rails_helper'

describe Structures::Community::MessageThreadsController do

  let(:structure) { FactoryGirl.create(:structure) }
  let!(:community) { FactoryGirl.create(:community, structure: structure) }

  before do
    5.times { community.message_threads.create }
  end

  describe 'GET #index' do
    context 'with json format' do
      it 'renders the community message threads' do
        get :index, structure_id: structure.slug, format: :json
        thread_ids = response_body['message_threads'].map { |t| t['id'] }
        expect(thread_ids).to match_array(community.message_threads.map(&:id))
      end
    end

    context 'with html format' do
      it 'redirects to the structure page' do
        get :index, structure_id: structure.slug
        expect(response).to redirect_to(structure_path(structure))
      end
    end
  end

  def response_body
    JSON.parse(response.body)
  end
end