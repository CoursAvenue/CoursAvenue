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

      it "doesn't creates a new admin" do
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
        expect(response).to redirect_to(
          new_course_pro_registrations_path(id: structure.slug, course_type: 'lesson')
        )
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
    let!(:structure) { structure = FactoryGirl.create(:structure) }
    context 'when the params are not valid' do
      # render_views

      let(:params) { { structure_course_creation_form:
                       { foo: 'bar',
                         course_type: 'Course::Lesson',
                         structure_id: structure.slug } } }

      it "doesn't create a new place" do
        expect { post :create_course, params }.to_not change { Place.count }
      end

      it "doesn't create a new course" do
        expect { post :create_course, params }.to_not change { Course.count }
      end

      # it "renders the course creation form" do
      #   post :create_course, params
      #   expect(response).to render_template('new')
      # end
    end

    context 'when the params are valid' do
      let(:params) { { structure_course_creation_form: valid_course_params(structure) } }

      it 'creates a new place' do
        expect { post :create_course, params }.to change { Place.count }.by(1)
      end

      it 'creates a new course' do
        expect { post :create_course, params }.to change { Course.count }.by(1)
      end

      it 'redirects to the user dashboard' do
        post :create_course, params
        expect(response).to redirect_to(pro_structure_path(structure))
      end
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

  def valid_course_params(structure)
    city = FactoryGirl.create(:city)
    subject_ = FactoryGirl.create(:subject_children)

    {
      structure_id: structure.slug,

      course_type: 'Course::Lesson',
      course_name: Faker::Name.name,
      course_subject_ids: [subject_.id],
      course_prices_attributes: [{ type:'Price::Trial', amount: 0 }],
      course_frequency: Course::COURSE_FREQUENCIES.sample,
      course_cant_be_joined_during_year: [true, false].sample,
      course_no_class_during_holidays: [true, false].sample,

      place_name: Faker::Name.name,
      place_street: Faker::Address.street_address,
      place_zip_code: Faker::Address.zip_code,
      place_city_id: city.id
    }
  end
end
