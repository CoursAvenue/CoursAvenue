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
      "parent_subjects_text",
      "parent_subjects",
      "child_subjects",
      "data_url",
      "subjects_count",
      "too_many_subjects",
      "subjects",
      "places"
    ]
  end

  describe :index, search: true do
    let(:structure) { FactoryGirl.build(:structure_with_place) }

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
      assigns(:structure_search).total.should eq(result['meta']['total'])
    end

  end

end

