require 'rails_helper'
include Devise::TestHelpers

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

      it 'renders the creation form' do
        post :create, params
        expect(response).to render_template('new')
      end
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
    # render_views

    let(:structure) { FactoryGirl.create(:structure_with_admin) }
    it 'assigns a course creation form' do
      get :new_course, { id: structure.slug }
      expect(assigns(:course_creation_form)).to be_a(Structure::CourseCreationForm)
    end

    # TODO: Find why it asks to authenticate ????
    # it 'renders the right partial depending on the course type' do
    #   get :new_course, { id: structure.slug, course_type: 'lesson' }
    #   expect(response).to render_template('_lesson')
    # end
  end

  describe 'POST #create_course' do
    let!(:structure) { structure = FactoryGirl.create(:structure_with_admin) }
    context 'when the params are not valid' do
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

      it "renders the course creation form" do
        post :create_course, params
        expect(response).to render_template('new_course')
      end
    end

    context 'when the params are valid' do
      let(:params) { { structure_course_creation_form: valid_course_params(structure) } }

      it 'creates a new place' do
        expect { post :create_course, params }.to change { Place.count }.by(1)
      end

      it 'creates a new course' do
        expect { post :create_course, params }.to change { Course.count }.by(1)
      end

      it 'creates a new planning' do
        expect { post :create_course, params }.to change { Planning.count }.by(1)
      end

      it 'redirects to the edit structure page' do
        post :create_course, params
        expect(response).to redirect_to(edit_pro_structure_path(structure))
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
    level = Level.all.sample.id
    audience = Audience.all.sample.id

    {
      structure_id: structure.slug,

      course_type: 'Course::Lesson',
      course_name: Faker::Name.name,
      course_description: Faker::Lorem.paragraph(3),
      course_subject_ids: [subject_.id],
      course_prices_attributes: { type:'Price::Trial', amount: 0 },
      course_frequency: Course::COURSE_FREQUENCIES.sample,
      course_cant_be_joined_during_year: [true, false].sample,
      course_no_class_during_holidays: [true, false].sample,

      planning_start_date: Date.tomorrow,
      planning_start_time: Time.parse("10:00"),
      planning_end_time: Time.parse("12:00"),
      planning_week_day: (0..7).to_a.sample,
      min_age_for_kid: 10,
      max_age_for_kid: 18,

      level_ids: [level],
      audience_ids: [audience],

      place_name: Faker::Name.name,
      place_street: Faker::Address.street_address,
      place_zip_code: Faker::Address.zip_code,
      place_city_id: city.id
    }
  end
end
