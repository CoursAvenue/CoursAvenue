# -*- encoding : utf-8 -*-
require 'spec_helper'

describe StructuresController do

  def required_keys
    [
      "id",
      "name",
      "slug",
      "comments_count",
      "rating",
      "street",
      "zip_code",
      "logo_present",
      "logo_thumb_url",
      "data_url",
      "places"
    ]
  end

  describe :show do
    let(:structure) { FactoryGirl.create(:structure_with_place) }
    it 'returns 200' do
      get :show, id: structure.id
    end
  end

  describe :index, search: true do
    let(:structure) { FactoryGirl.build(:structure_with_place) }
    let(:subject) { Subject.first }

    before do
      @structure = FactoryGirl.create(:structure_with_place)
      Sunspot.commit
    end

    it "renders structures with the json required by filtered search" do
      get :index, format: :json, lat: 48.8592, lng: 2.3417
      response.should be_success
      result = JSON.parse(StructureSerializer.new(@structure, {root: false}).to_json)

      result.keys.should include(*required_keys) # splat ^o^//
    end

    it "includes 'meta' in the rendered json" do
      get :index, format: :json, lat: 48.8592, lng: 2.3417
      response.should be_success

      result = JSON.parse(response.body)
      result.keys.should include('meta')
      assigns(:total).should eq(result['meta']['total'])
    end

    it "sets params[:other] when subject_id is 'other'" do
      get :index, format: :json, lat: 48.8592, lng: 2.3417, subject_id: 'other'

      expect(controller.params[:other]).to be_true
      expect(controller.params).not_to have_key(:subject_id)
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

  describe :show do
    let(:structure) { FactoryGirl.create(:structure_with_place) }
    it 'returns 200' do
      get :show, id: structure.id
      expect(response.status).to eq(200)
    end
  end
end
