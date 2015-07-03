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
        expect(response).to redirect_to(new_course_pro_registrations_path(id: structure.slug,
                                                                          course_type: 'lesson'))
      end
    end
  end

  describe 'GET #new_course' do
    let(:structure) { FactoryGirl.create(:structure) }
    it 'assigns a course creation form' do
      get :new_course, { id: structure.slug }
      expect(assigns(:course_creation_form)).to be_a(Structure::CourseCreationForm)
    end

    it 'renders the right partial depending on the course type'
  end

  describe 'POST #create_course' do
    context 'when the params are not valid' do
      it "doesn't create a new course"
      it "renders the course creation form"
    end

    context 'when the params are valid' do
      it 'creates a new course'
      it 'redirects to the user dashboard'
    end
  end

  def valid_registration_params
    structure_subject = FactoryGirl.create(:subject_children)
    root_subject = structure_subject.root
    {
      structure_name: Faker::Name.name + ' Institute',
      structure_subjects_ids: [root_subject.id],
      structure_subject_descendants_ids: [structure_subject.id],

      admin_email: Faker::Internet.email,
      admin_password: Faker::Internet.password,

      course_type: 'lesson'
    }
  end
end
