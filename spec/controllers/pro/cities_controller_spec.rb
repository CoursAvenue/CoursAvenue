require "spec_helper"

describe Pro::CitiesController do

  before(:each) do
    @request.host = "pro.courseavenue..com"
  end

  context 'connected' do
    let(:admin) { FactoryGirl.create(:admin) }

    before do
      sign_in admin
    end

    describe :index do
      it 'returns 200' do
        get :index, subdomain: 'pro'
        expect(response.status).to eq(200)
      end
    end
  end

  context 'not connected' do
    describe :zip_code_search do
      it 'returns 200' do
        get :zip_code_search, format: :json, subdomain: 'pro'
        expect(response.status).to eq(200)
      end
    end
  end

end
