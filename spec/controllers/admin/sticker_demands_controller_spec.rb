require 'rails_helper'

describe Admin::StickerDemandsController do
  include Devise::TestHelpers

  let(:admin) { FactoryGirl.create(:super_admin) }

  before { sign_in admin }

  describe 'GET #index' do
    it 'assigns the demands' do
      get :index
      stickers = 5.times.map { StickerDemand.create }
      expect(assigns(:sticker_demands)).to match_array(stickers)
    end

    it do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
