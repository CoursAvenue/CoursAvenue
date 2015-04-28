# -*- encoding : utf-8 -*-
require 'rails_helper'

describe ParticipationRequestsController, type: :controller do
  include Devise::TestHelpers

  let (:participation_request) { FactoryGirl.create(:participation_request) }
  let (:structure)             { FactoryGirl.create(:structure) }
  let (:user)                  { FactoryGirl.create(:user) }
  let (:planning)              { FactoryGirl.create(:planning) }

  context 'on WWW Subdomain' do
    context 'user signed in' do
      before(:each) { sign_in participation_request.user }

      describe '#edit' do
        it 'returns 200' do
          get :edit, id: participation_request.token
          expect(response.status).to eq 200
        end
      end
      describe '#accept_form' do
        it 'returns 200' do
          get :accept_form, id: participation_request.token
          expect(response.status).to eq 200
        end
      end
      describe '#cancel_form' do
        it 'returns 200' do
          get :cancel_form, id: participation_request.token
          expect(response.status).to eq 200
        end
      end
      describe '#report_form' do
        it 'returns 200' do
          get :report_form, id: participation_request.token
          expect(response.status).to eq 200
        end
      end
    end
    context 'user is not signed in' do
      describe '#edit' do
        it 'returns 200' do
          get :edit, id: participation_request.token
          expect(response).to be_redirect
        end
      end
    end
  end
  context 'on structure subdomain with a user signed in' do
    before(:each) do
      @request.host = "#{participation_request.structure.slug}.example.com"
    end
    describe '#edit' do
      it 'returns 200' do
        get :edit, id: participation_request.token
        expect(response.status).to eq 200
      end
      it 'redirects if id was given' do
        get :edit, id: participation_request.id
        expect(response).to be_redirect
      end
    end
    describe '#accept_form' do
      it 'returns 200' do
        get :accept_form, id: participation_request.token
        expect(response.status).to eq 200
      end
    end
    describe '#cancel_form' do
      it 'returns 200' do
        get :cancel_form, id: participation_request.token
        expect(response.status).to eq 200
      end
    end
    describe '#report_form' do
      it 'returns 200' do
        get :report_form, id: participation_request.token
        expect(response.status).to eq 200
      end
    end
    describe '#accept' do
      it 'accepts and redirect' do
        patch :accept, id: participation_request.token,
                        participation_request: {
                          message: { body: 'Lorem' }
                        }
        expect(assigns(:participation_request).accepted?).to be_truthy
        expect(response).to be_redirect
      end
    end
    describe '#modify_date' do
      it 'modify_date and redirect' do
        patch :modify_date, id: participation_request.token,
                        participation_request: {
                          message: { body: 'Lorem' }
                        }
        expect(assigns(:participation_request).pending?).to be_truthy
        expect(response).to be_redirect
      end
    end
    describe '#discuss' do
      it 'discuss and redirect' do
        patch :discuss, id: participation_request.token,
                        participation_request: {
                          message: { body: 'Lorem' }
                        }
        expect(assigns(:participation_request).pending?).to be_truthy
        expect(response).to be_redirect
      end
    end
    describe '#cancel' do
      it 'cancel and redirect' do
        patch :cancel, id: participation_request.token,
                        participation_request: {
                          message: { body: 'Lorem' }
                        }
        expect(assigns(:participation_request).canceled?).to be_truthy
        expect(response).to be_redirect
      end
    end
    describe '#report' do
      it 'reports and redirect ' do
        patch :report, id: participation_request.token,
                        participation_request: {
                        }
        expect(response).to be_redirect
      end
    end
  end
end

