require 'rails_helper'

describe ApplicationController do
  # Creating dummy routes to make sure errors are properly handled.
  controller(ApplicationController) do
    def index
      raise 'A random error'
    end

    def show
      structure = Structure.find(params[:id])
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
end
