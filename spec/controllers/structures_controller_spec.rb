# -*- encoding : utf-8 -*-
require 'rails_helper'

describe StructuresController, type: :controller do
  include Devise::TestHelpers

  def required_keys
    %w(id name slug comments_count logo_thumb_url logo_large_url data_url
      query_params structure_type highlighted_comment_title has_promotion
      is_open_for_trial cover_media subjects current_filtered_subject_name cities_text
      min_price_amount places preloaded_medias)
  end

  describe 'show' do
    let(:structure) { FactoryGirl.create(:structure_with_place) }
    it 'returns 200' do
      get :show, id: structure.id
      expect(response.status).to eq(200)
    end
  end

  describe 'index', search: true do
    let(:structure) { FactoryGirl.build(:structure_with_place) }
    let(:subject) { Subject.first }

    before do
      @structure = FactoryGirl.create(:structure_with_place)
      Sunspot.commit
    end

    it "renders structures with the json required by filtered search" do
      get :index, format: :json, lat: 48.8592, lng: 2.3417
      expect(response).to have_http_status(:success)
      result = JSON.parse(StructureSerializer.new(@structure, { root: false }).to_json)

      expect(result.keys).to include(*required_keys)
    end

    it "includes 'meta' in the rendered json" do
      get :index, format: :json, lat: 48.8592, lng: 2.3417
      expect(response).to have_http_status(:success)

      result = JSON.parse(response.body)
      expect(result.keys).to include('meta')

      expect(assigns(:total)).to eq(result['meta']['total'])
    end

    it "correctly finds the subject if subject_id is provided" do
      get :index, format: :json, lat: 48.8592, lng: 2.3417, subject_id: subject.slug

      expect(assigns(:subject)).to eq(subject)
      expect(controller.params).to have_key(:subject_id)
    end

    it "guesses the subject if params[:name] matches any subject" do
      get :index, format: :json, lat: 48.8592, lng: 2.3417, name: subject.name

      expect(assigns(:subject)).to eq(subject)
    end
  end

  describe 'follow' do
    let(:user) { FactoryGirl.create(:user) }
    let(:structure) { FactoryGirl.create(:structure_with_admin) }
    before do
      sign_in user
    end

    it 'creates a new following' do
      followings_count = structure.followings.count
      post :add_to_favorite, id: structure.id

      expect(structure.followings.count).to eq followings_count + 1
    end

    # We freezed the metrics
    # it 'creates a new Metric action' do
    #   expect { post :add_to_favorite, id: structure.id }.to change { structure.metrics.actions.count }.by(1)
    # end
  end
end
