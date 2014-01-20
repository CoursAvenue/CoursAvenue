# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Pro::Structures::UserProfilesController do
  let(:admin) { FactoryGirl.create(:admin) }

  let(:structure) { FactoryGirl.create(:structure_with_user_profiles) }
  let(:user_profile) { structure.user_profiles.first }

  let(:ids)       { structure.user_profiles.map(&:id) }
  let(:length)    { structure.user_profiles.to_a.length }

  before do
    sign_in admin

    # normally we are testing the result of the job
    Delayed::Worker.delay_jobs = false
  end

  describe :index do
    it "includes 'meta' in the rendered json" do
      get :index, format: :json, structure_id: structure.id
      response.should be_success

      result = JSON.parse(response.body)
      result.keys.should include('meta')
      assigns(:user_profiles_search).total.should eq(result['meta']['total'])
      assigns(:structure).busy.should eq(result['meta']['busy'])
    end
  end

  describe :edit do
    context "when format is html" do
      it "responds to an xhr request" do
        xhr :get, :edit, format: :html, id: user_profile.id, structure_id: structure.id

        response.should be_success
      end
    end

  end

  describe :create do

    it "does not create tags if no tags are given" do
      post :create, format: :json, id: user_profile.id, structure_id: structure.id, user_profile: { email: "bob@email.com" }

      expect(JSON.parse(response.body)).to include("tags" => [])
    end

    it "responds with a CSV of the tags in tag_name" do
      post :create, format: :json, id: user_profile.id, structure_id: structure.id, user_profile: { email: "bob@email.com", tags: ["this", "that"] }

      tag_name = JSON.parse(response.body)["tags"].map { |h| h["name"] }.join(", ")
      expect(JSON.parse(response.body)).to include("tag_name" => tag_name)
    end

    it "creates a profile with tags if given" do
      post :create, format: :json, id: user_profile.id, structure_id: structure.id, user_profile: { email: "bob@email.com", tags: ["this", "that"] }

      tags = JSON.parse(response.body)["tags"].map { |h| h["name"] }
      expect(tags).to match_array(["this", "that"])
    end

  end

  describe :update do
    it "does not change the tags if no tags are given" do
      put :update, format: :json, id: user_profile.id, structure_id: structure.id, user_profile: { }

      expect(JSON.parse(response.body)).to include("tags" => [])
    end

    it "updates tags if applicable" do
      put :update, format: :json, id: user_profile.id, structure_id: structure.id, user_profile: { tags: ["this", "that"] }

      tags = JSON.parse(response.body)["tags"].map { |h| h["name"] }
      expect(tags).to match_array(["this", "that"])
    end
  end

end

