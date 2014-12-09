# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Pro::Structures::TagsController do
  let(:admin)     { FactoryGirl.create(:admin) }
  let(:structure) { structure = admin.structure }

  before do
    sign_in admin
  end

  describe 'index' do
    let(:user_profile) { FactoryGirl.create(:user_profile_with_tags) }
    let(:structure)    { user_profile.structure }

    let(:tags)       { structure.owned_tags }

    it "returns all the tags" do
      get :index, format: :json, structure_id: structure.id

      expect(assigns(:tags).length).to eq(2)
    end

    it "returns 200" do
      get :index, structure_id: structure.id

      expect(response).to be_success
    end
  end

  describe 'new' do
    it "returns 200" do
      xhr :get, :new, structure_id: structure.id
      expect(response).to be_success
    end
  end

  describe 'create' do
    it 'creates a new tag' do
      post :create, structure_id: structure.id, tag: { name: 'foo'}
      expect(structure.owned_tags.map(&:name)).to include 'foo'
    end
  end

  context 'with_existing_tag' do
    before do
      structure.create_tag 'foo'
    end

    describe 'edit' do
      it "returns 200" do
        xhr :get, :edit, structure_id: structure.id, id: structure.owned_tags.last
        expect(response).to be_success
      end
    end

    describe 'update' do
      it "updates a tag" do
        @tag = structure.owned_tags.last
        put :update, structure_id: structure.id, id: @tag.id, tag: { name: 'bar'}
        expect(@tag.reload.name).to eq 'bar'
      end
    end
  end

end
