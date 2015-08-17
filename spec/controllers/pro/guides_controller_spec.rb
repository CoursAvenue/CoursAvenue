require 'rails_helper'

describe Pro::GuidesController, user_guide: true do
  include Devise::TestHelpers

  it { should use_before_action(:authenticate_pro_super_admin!) }

  let!(:admin) { FactoryGirl.create(:super_admin) }
  before { sign_in admin }

  describe 'GET #index' do
    render_views
    it 'renders the index template' do
      get :index
      expect(:response).to render_template('index')
    end

    context 'when there are guides' do
      it 'renders the empty partial guide' do
        get :index
        expect(:response).to render_template(partial: '_guides_empty')
      end

      it 'assigns nothing' do
        get :index
        expect(assigns(:guides)).to be_empty
      end
    end

    context 'when there are guides' do
      let!(:guides) {[ FactoryGirl.create(:guide), FactoryGirl.create(:guide) ]}
      it 'renders the empty partial guide' do
        get :index
        expect(:response).to render_template(partial: '_guides_list')
      end

      it 'assigns nothing' do
        get :index
        expect(assigns(:guides)).to match_array(guides)
      end
    end
  end

  describe 'GET #show' do
    let(:guide) { FactoryGirl.create(:guide) }

    context 'html format' do
      it 'redirects to the guide' do
        get :show, id: guide.slug
        expect(response).to redirect_to(edit_pro_guide_path(guide))
      end
    end

    context 'json format' do
      it 'renders the guide as json' do
        get :show, id: guide.slug, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(guide.id)
      end
    end
  end

  describe 'GET #new' do
    render_views

    it 'assigns a new guide' do
      get :new
      expect(assigns(:guide)).to be_a_new(Guide)
    end

    it 'renders the form' do
      get :new
      expect(:response).to render_template(partial:'_form')
    end
  end

  describe 'POST #create' do
    context 'with invalid params' do
      render_views
      let(:params) { { guide: { foo: 'bar' } } }
      it "doens't create a guide" do
        expect { post :create, params }.to_not change { Guide.count }
      end

      it 'renders the `new` template' do
        post :create, params
        expect(response).to render_template('new')
      end
    end

    context 'with valid params' do
      let(:params) { { guide: valid_guide_params } }

      it 'creates a new guide' do
        expect { post :create, params }.to change { Guide.count }.by(1)
      end

      it 'creates new questions' do
        expect { post :create, params }.to change { Guide::Question.count }.by(2)
      end

      it 'creates new answers' do
        expect { post :create, params }.to change { Guide::Answer.count }.by(2)
      end

      it 'redirect to the subject edition form' do
        post :create, params
        guide = Guide.last
        expect(response).to redirect_to(edit_subjects_pro_guide_path(guide))
      end
    end
  end

  describe 'GET #edit' do
    render_views

    let(:guide) { FactoryGirl.create(:guide) }

    it 'assigns an existing guide' do
      get :edit, id: guide.id
      expect(assigns(:guide)).to be_a(Guide)
    end

    it 'renders the form' do
      get :edit, id: guide.id
      expect(:response).to render_template(partial:'_form')
    end
  end

  describe 'PATCH #update' do
    let(:guide) { FactoryGirl.create(:guide) }

    context 'with invalid params' do
      render_views

      let(:invalid_params) { { title: nil, foo: 'bar' } }

      it "doesn't update the guide" do
        expect { patch :update, { id: guide.id, guide: invalid_params } }.to_not change { guide }
      end

      it 'renders the `edit` template' do
        patch :update, { id: guide.id, guide: invalid_params }
        expect(response).to render_template('edit')
      end
    end

    context 'with valid params' do
      it 'updates the guide' do
        current_title = guide.title
        updated_title = guide.title + " updated"
        expect { patch :update, { id: guide.id, guide: valid_updated_guide_params(guide) }; guide.reload }.
          to change { guide.title }.from(current_title).to(updated_title)
      end

      it 'redirect to the subject edition form' do
        patch :update, { id: guide.id, guide: valid_updated_guide_params(guide) }
        expect(response).to redirect_to(edit_subjects_pro_guide_path(guide))
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:guide) { FactoryGirl.create(:guide) }

    it 'destroys the guide' do
      delete :destroy, id: guide.id
      expect(Guide.where(id: guide.id)).to be_empty
    end

    it 'redirects to the guide list' do
      delete :destroy, id: guide.id
      expect(response).to redirect_to(pro_guides_path)
    end
  end

  describe 'GET #edit_subjects' do
    render_views

    let(:guide) { stub_full_guide }

    it 'assigns the guide' do
      get :edit_subjects, id: guide.id
      expect(assigns(:guide)).to eq(guide)
    end

    it 'renders the subject edition form' do
      get :edit_subjects, id: guide.id
      expect(response).to render_template('edit_subjects')
    end
  end

  describe 'PATCH #update_subjects' do
    let(:guide) { stub_full_guide }
    let(:valid_subject_params) { valid_subjects_params(guide) }

    it 'updates the subject' do
      subject_ = guide.subjects.first
      patch :update_subjects, { id: guide.id, guide: { subjects_attributes: valid_subject_params } }

      subject_.reload
      expect(subject_.guide_description).to_not be_nil
    end

    it 'redirects to the guides index page' do
      patch :update_subjects, { id: guide.id, guide: { subjects_attributes: valid_subject_params } }
      expect(response).to redirect_to(pro_guides_path)
    end
  end

  def valid_guide_params
    subject_ = FactoryGirl.create(:subject)
    q1 = { content: Faker::Lorem.sentence, ponderation: 0, position: 1,
           answers_attributes: [
             { content: Faker::Lorem.sentence, subject_ids: [ subject_.id ] }
    ] }
    q2 = { content: Faker::Lorem.sentence, ponderation: 0, position: 2,
           answers_attributes: [
             { content: Faker::Lorem.sentence, subject_ids: [ subject_.id ] }
    ] }

    {
      title: Faker::Lorem.sentence,
      description: Faker::Lorem.paragraph(3),
      call_to_action: Faker::Lorem.sentence,
      questions_attributes: [q1, q2]
    }
  end

  def valid_updated_guide_params(guide)
    {
      title: guide.title + " updated"
    }
  end

  def stub_full_guide
    guide     = FactoryGirl.create(:guide)
    question = FactoryGirl.create(:guide_question, guide: guide)
    answers   = 5.times { FactoryGirl.create(:guide_answer, :with_subjects, question: question) }

    guide.reload
  end

  def valid_subjects_params(guide)
    { "0" => {
        id: guide.subjects.first.id,
        guide_description: Faker::Lorem.sentence(10)
      }
    }
  end
end
