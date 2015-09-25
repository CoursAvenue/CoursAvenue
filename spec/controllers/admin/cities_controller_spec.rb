require "rails_helper"

describe Admin::CitiesController do
  include Devise::TestHelpers

  context 'not connected' do
    describe 'zip_code_search' do
      it 'returns 200' do
        get :zip_code_search, format: :json, subdomain: 'pro'
        expect(response.status).to eq(200)
      end
    end
  end
end
