require "rails_helper"

describe Admin::CitiesController do
  include Devise::TestHelpers

  it { should use_before_action(:authenticate_pro_super_admin!) }

  describe '#zip_code_search' do
    it 'returns 200' do
      get :zip_code_search, format: :json, subdomain: 'pro'
      expect(response.status).to eq(200)
    end

    # it 'returns the cities in JSON' do
    #   city = FactoryGirl.create(:city, name: Faker::Name.name, zip_code: Faker::Number.number(5))
    #   city.index!
    #
    #   get :zip_code_search, { term: city.zip_code.to_s, format: :json }
    #   ids = JSON.parse(response.body).map { |c| c['id'] }
    #
    #   expect(ids).to match_array([city.id])
    # end
  end

  describe '#edit' do
    it 'should assign the city' do
      admin = FactoryGirl.create(:super_admin)
      sign_in admin

      city = FactoryGirl.create(:city)
      get :edit, id: city.id

      expect(assigns(:city)).to eq(city)
    end

    it 'renders the edit template' do
      admin = FactoryGirl.create(:super_admin)
      sign_in admin

      city = FactoryGirl.create(:city)
      get :edit, id: city.id

      expect(response).to render_template('edit')
    end
  end

  describe '#update' do
    it 'redirect to the index' do
      admin = FactoryGirl.create(:super_admin)
      sign_in admin

      city = FactoryGirl.create(:city)
      new_name = 'Rosoy'
      post :update, id: city.id, city: { name: new_name }

      expect(city.reload.name).to eq(new_name)
    end

    it 'redirect to the index' do
      admin = FactoryGirl.create(:super_admin)
      sign_in admin

      city = FactoryGirl.create(:city)
      new_name = 'Rosoy'
      post :update, id: city.id, city: { name: new_name }

      expect(response).to redirect_to(admin_cities_path)
    end
  end

end
