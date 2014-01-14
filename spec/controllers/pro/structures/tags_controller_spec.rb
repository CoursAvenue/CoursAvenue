# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Pro::Structures::TagsController do
  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  describe :index do
    let(:user_profile) { FactoryGirl.create(:user_profile_with_tags) }
    let(:structure) { user_profile.structure }

    let(:tags)       { structure.owned_tags }

    it "returns all the tags" do
      get :index, format: :json, structure_id: structure.id

      expect(assigns(:tags).length).to eq(2)
    end

  end

end

