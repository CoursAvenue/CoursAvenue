require 'rails_helper'

describe Pro::RegistrationsController do
  describe 'GET #new' do
    it 'assigns a registration form' do
      get :new
      expect(assigns(:registration_form)).to be_a(Structure::RegistrationForm)
    end
  end

  describe 'POST #create' do
    context 'when the params are not valid' do
      let(:params) { { structure_registration_form: { foo: 'bar' } } }

      it "doesn't create a new structure" do
        expect{ post :create, params }.to_not change { Structure.count }
      end

      it "creates a new admin" do
        expect { post :create, params }.to_not change { Admin.count }
      end

      it 'renders the creation form'
    end

    context 'when the params are valid' do
      let(:params) { { structure_registration_form: valid_registration_params } }

      it 'creates a new structure' do
        expect { post :create, params }.to change { Structure.count }.by(1)
      end

      it 'creates a new admin' do
        expect { post :create, params }.to change { Admin.count }.by(1)
      end

      it 'redirects to the second part of the registration' do
        post :create, params
        structure = Structure.last
        expect(response).to redirect_to(new_course_pro_registrations_path(id: structure.slug))
      end
    end
  end
end
