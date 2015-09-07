# -*- encoding : utf-8 -*-
require 'rails_helper'

describe StructuresController, type: :controller do
  include Devise::TestHelpers

  def required_keys
    %w(id name slug comments_count logo_thumb_url logo_large_url data_url
      query_params structure_type highlighted_comment_title has_promotion
      is_open_for_trial cover_media subjects cities_text
      min_price_amount places preloaded_medias)
  end

  describe 'show' do
    let(:structure) { FactoryGirl.create(:structure_with_place) }
    it 'returns 200' do
      get :show, id: structure.slug
      expect(response.status).to eq(200)
    end
  end

  describe 'follow' do
    let(:user) { FactoryGirl.create(:user) }
    let(:structure) { FactoryGirl.create(:structure_with_admin) }

    before { sign_in user }

    it 'creates a new favorites' do
      followings_count = structure.user_favorites.count
      post :add_to_favorite, id: structure.slug

      expect(structure.user_favorites.count).to eq followings_count + 1
    end
  end
end
