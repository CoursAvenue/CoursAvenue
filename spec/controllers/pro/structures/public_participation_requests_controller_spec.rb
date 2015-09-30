require 'rails_helper'

describe Pro::Structures::PublicParticipationRequestsController do
  include Devise::TestHelpers

  it { should use_before_action(:load_structure) }

  describe 'GET #edit' do
    it 'renders the edit template' do
      pr = FactoryGirl.create(:participation_request)
      structure = pr.structure

      get :edit, structure_id: structure.slug, id: pr.token
      expect(response).to render_template('edit')
    end
  end

  describe 'GET #show' do
    it 'renders the show template' do
      pr = FactoryGirl.create(:participation_request)
      structure = pr.structure

      get :show, structure_id: structure.slug, id: pr.token
      expect(response).to render_template('show')
    end

    context 'when the user has been deleted' do
      it 'redirects to the participation request list' do
        pr = FactoryGirl.create(:participation_request)
        structure = pr.structure
        pr.user.destroy

        get :show, structure_id: structure.slug, id: pr.token
        expect(response).to redirect_to(pro_structure_participation_requests_path(pr.structure))
      end
    end
  end

  describe 'GET #show_user_contacts' do
    it 'renders the show_user_contacts template' do
      pr = FactoryGirl.create(:participation_request)
      structure = pr.structure

      get :show_user_contacts, structure_id: structure.slug, id: pr.token
      expect(response).to render_template('show_user_contacts')
    end

    context 'when the participation request is pending' do
      it 'treats the participation request' do
        pr = FactoryGirl.create(:participation_request)
        structure = pr.structure

        get :show_user_contacts, structure_id: structure.slug, id: pr.token

        pr.reload
        expect(pr).to be_pending
      end
    end

  end

  describe 'GET #cancel_form' do
    it 'renders the cancel_form template' do
      pr = FactoryGirl.create(:participation_request)
      structure = pr.structure

      get :cancel_form, structure_id: structure.slug, id: pr.token
      expect(response).to render_template('cancel_form')
    end

  end

  describe 'PUT #accept' do
    it 'update the participation request state' do
      pr = FactoryGirl.create(:participation_request)
      structure = pr.structure

      put :accept, structure_id: structure.slug, id: pr.token

      pr.reload
      expect(pr).to be_accepted
    end

    it 'redirects to the participation request' do
      pr = FactoryGirl.create(:participation_request)
      structure = pr.structure

      put :accept, structure_id: structure.slug, id: pr.token
      expect(response).to redirect_to(
        pro_structure_public_participation_request_path(pr.structure, pr))
    end
  end
end
