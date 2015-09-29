require 'rails_helper'

describe ApplicationController do
  include Devise::TestHelpers

  # Creating dummy routes to make sure errors are properly handled.
  controller(ApplicationController) do
    before_filter :authenticate_user!, only: [:update]

    def index
      raise 'A random error'
    end

    def show
      structure = Structure.find(params[:id])
      render nothing: true
    end

    def update
      # Should raise since we are trying to update another user
      user = User.find(params[:id])
      user.first_name = Faker::Name.first_name
      user.save

      render nothing: true
    end
  end

  describe 'GET #index -> render_error' do
    it 'renders the interal error template' do
      get :index
      expect(response).to render_template('errors/internal_server_error')
    end

    it 'sets the status as not found' do
      get :index
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show -> render_not_found' do
    context 'when the structure has been deleted' do
      it 'redirects to the most relevant search page' do
        structure = FactoryGirl.create(:structure, :deleted)
        get :show, id: structure.slug

        expect(response).to redirect_to(root_search_page_path(
          structure.dominant_root_subject, structure.city, subdomain: 'www'))
      end

      it 'redirects with permanent move code' do
        structure = FactoryGirl.create(:structure, :deleted)
        get :show, id: structure.slug

        expect(response).to have_http_status(:moved_permanently)
      end
    end

    context 'when the structure never existed' do
      it 'redirects to the root page' do
        get :show, id: Faker::Name.name.parameterize
        expect(response).to redirect_to(root_path)
      end

      it 'redirects with permanent move code' do
        get :show, id: Faker::Name.name.parameterize
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end

  describe 'PUT #update -> not_allowed' do
    xit 'redirects to the root_path' do
      logged_in_user = FactoryGirl.create(:user)
      other_user = FactoryGirl.create(:user)

      sign_in logged_in_user
      put :update, id: other_user.id

      expect(response).to redirect_to(root_url(subdomain: 'www'))
    end

    xit 'redirects with an alert' do
      logged_in_user = FactoryGirl.create(:user)
      other_user = FactoryGirl.create(:user)

      sign_in logged_in_user
      put :update, id: other_user.id

      expect(flash[:success]).to eq(I18n.t('devise.failure.unauthenticated'))
    end
  end
end
