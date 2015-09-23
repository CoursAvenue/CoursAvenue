require 'rails_helper'

describe Admin::PlacesController do
  include ActionDispatch::TestProcess
  include Devise::TestHelpers

  describe '#index' do
    it 'is successfull' do
      admin = FactoryGirl.create(:super_admin)
      sign_in admin

      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
