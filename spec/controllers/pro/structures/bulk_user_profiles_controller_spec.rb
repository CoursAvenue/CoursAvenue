# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Pro::Structures::BulkUserProfilesController do
  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin

    # normally we are testing the result of the job
    Delayed::Worker.delay_jobs = false
  end

  describe :create do
    let(:structure) { FactoryGirl.create(:structure_with_user_profiles) }

    let(:ids)       { structure.user_profiles.map(&:id) }
    let(:length)    { structure.user_profiles.to_a.length }

    it "creates a delayed job" do
      Delayed::Worker.delay_jobs = true # we want to test that the job is being created

      expect {
        post :create, format: :json, ids: ids, tags: [{ name: "happy"}, { name: "tall"}], structure_id: structure.id
      }.to change(Delayed::Job, :count).by(1)
    end

    it "creates a bulk update for the profiles with the given ids" do
      post :create, format: :json, ids: ids, tags: [{ name: "happy"}, { name: "tall"}], structure_id: structure.id

      expect(assigns(:user_profiles).length).to eq(3)
    end

    it "it creates a bulk update for all profiles" do
      post :create, format: :json, ids: "all", tags: [{ name: "happy"}, { name: "tall"}], structure_id: structure.id

      expect(assigns(:user_profiles).length).to eq(length)
    end

  end

end

