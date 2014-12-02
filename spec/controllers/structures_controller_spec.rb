# -*- encoding : utf-8 -*-
require 'spec_helper'

describe StructuresController, type: :controller do

  def required_keys
    %w(id name slug comments_count logo_thumb_url logo_large_url data_url
      query_params structure_type highlighted_comment_title premium has_promotion
      is_open_for_trial cities cover_media subjects trial_courses_policy places
      comments medias preloaded_medias)
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
    before do
      sign_in user
    end

    let(:structure) { FactoryGirl.create(:structure_with_admin) }

    it 'creates a new following' do
      followings_count = structure.followings.count
      post :add_to_favorite, id: structure.id

      expect(structure.followings.count).to eq followings_count + 1
    end
    it 'creates a new Statistic action' do
      actions_count = structure.statistics.actions.count
      post :add_to_favorite, id: structure.id
      expect(structure.statistics.actions.count).to eq actions_count + 1
    end
  end
end
