require 'rails_helper'

describe Pro::GuidesController, user_guide: true do
  include Devise::TestHelpers

  it { should use_before_action(:authenticate_pro_super_admin!) }

  let!(:admin) { FactoryGirl.create(:super_admin) }
  before { sign_in admin }

  describe '#index' do
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
end
