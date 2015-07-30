require 'rails_helper'

describe GuidesController, user_guide: true do
  it { should use_before_action(:set_guide) }

  describe 'GET #show' do
    let(:guide) { FactoryGirl.create(:guide) }

    it 'assigns a guide' do
      get :show, id: guide.slug
      expect(assigns(:guide)).to eq(guide)
    end

    it 'renders the show template' do
      get :show, id: guide.slug
      expect(response).to render_template('show')
    end
  end
end
