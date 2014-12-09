require "rails_helper"

describe Pro::StructuresController do
  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  context 'member' do
    describe "GET #update_widget_status" do
      it "redirects" do
        get :update_widget_status, id: admin.structure.slug
        expect(response).to be_redirect
      end
      it "updates the widget status" do
        get :update_widget_status, id: admin.structure.slug, status: Structure::WIDGET_STATUS.first
        expect(assigns(:structure).widget_status).to eq Structure::WIDGET_STATUS.first
      end
    end

    describe "GET #signature" do
      it "redirects" do
        get :signature, id: admin.structure.slug
        expect(response).to be_success
      end
    end

    describe "GET #widget" do
      it "redirects" do
        get :widget, id: admin.structure.slug
        expect(response).to be_success
      end
    end
    describe "GET #widget_ext" do
      it "'s a success" do
        get :widget_ext, id: admin.structure.slug, format: :json
        expect(response).to be_success
      end

      it 'sets the correct headers' do
        get :widget_ext, id: admin.structure.slug, format: :json
        expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(response.headers['Access-Control-Allow-Methods']).to eq 'GET, OPTIONS'
        expect(response.headers['Access-Control-Max-Age']).to eq '1728000'
        expect(response.headers['Access-Control-Allow-Headers']).to eq 'X-Requested-With, X-Prototype-Version, X-CSRF-Token'
      end
    end

    describe "GET #wizard" do
      it "'s a success" do
        get :wizard, id: admin.structure.slug, format: :json
        expect(response).to be_success
      end
    end

    describe "GET #dashboard" do
      it "'s a success" do
        get :dashboard, id: admin.structure.slug
        expect(response).to be_success
      end
    end

    describe "GET #crop_logo" do
      it "redirects if structure does not have a logo" do
        get :crop_logo, id: admin.structure.slug
        expect(response).to be_redirect
      end
      # it "'s a success if structure has a logo" do
      #   admin.structure.stub_chain(:logo, :present? ).and_return { true }
      #   get :crop_logo, id: admin.structure.slug
      #   expect(response).to be_success
      # end
    end
    describe "GET #edit" do
      it "'s a success" do
        get :edit, id: admin.structure.slug
        expect(response).to be_success
      end
    end

    describe "GET #add_subjects" do
      it "'s a success" do
        xhr :get, :add_subjects, id: admin.structure.slug
        expect(response).to be_success
      end
    end

    describe "GET #edit" do
      it "'s a success" do
        get :edit, id: admin.structure.slug
        expect(response).to be_success
      end
    end

    describe "PUT #update" do
      it "'s a success" do
        patch :update, id: admin.structure.slug, structure: {}
        expect(response).to be_redirect
      end
    end
  end

  context 'collection' do
    describe "GET #best" do
      it "'s a success" do
        get :best, format: :json
        expect(response).to be_success
      end
    end

    # describe "GET #stars" do
    #   it "'s a success" do
    #     admin.super_admin = true
    #     get :stars
    #     expect(response).to be_success
    #   end
    # end

    describe "GET #index" do
      it 'is forbidden' do
        expect { get :index }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe "GET #new" do
      it "'s a success" do
        xhr :get, :new
        expect(response).to be_success
      end
    end
  end
end
