# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Structures::ParticipationRequestsController, type: :controller do
  include Devise::TestHelpers

  let (:participation_request) { FactoryGirl.create(:participation_request) }
  let (:structure)             { FactoryGirl.create(:structure) }
  let (:user)                  { FactoryGirl.create(:user) }
  let (:planning)              { FactoryGirl.create(:planning) }

  context 'User is signed in' do
    before do
      sign_in user
    end

    describe '#create' do
      before(:each) do
        request.env["HTTP_ACCEPT"] = 'application/json'
      end

      context 'when resource is found' do
        it 'creates a participation_request' do
          post :create, { format: :json,
                          structure_id: participation_request.structure.slug,
                          participation_request: {
                            planning_id: planning.id,
                            date: Date.tomorrow.to_s,
                            structure_id: structure.id,
                            message: {
                              body: 'Lorem'
                            },
                            user: {
                              phone_number: '021402104',
                              name: 'Lorem',
                              email: 'lorem@ipsum.com'
                            }
                          }
                        }
          expect(assigns(:participation_request)).to be_persisted
        end

        it 'updates existing user' do
          post :create, { structure_id: participation_request.structure.slug,
                          participation_request: {
                            structure_id: structure.id,
                            message: {
                              body: 'Lorem'
                            },
                            user: {
                              phone_number: '021402104'
                            }
                          }
                        }
          expect(user.reload.phone_number).to eq '021402104'
        end
      end
    end
  end

  context 'on WWW Subdomain' do
    context 'user signed in' do
      before(:each) { sign_in participation_request.user }

      describe '#edit' do
        it 'returns 200' do
          get :edit, structure_id: participation_request.structure.slug,
                         id: participation_request.token
          expect(response.status).to eq 200
        end
      end
      describe '#accept_form' do
        it 'returns 200' do
          get :accept_form, structure_id: participation_request.structure.slug,
                         id: participation_request.token
          expect(response.status).to eq 200
        end
      end
      describe '#cancel_form' do
        it 'returns 200' do
          get :cancel_form, structure_id: participation_request.structure.slug,
                         id: participation_request.token
          expect(response.status).to eq 200
        end
      end
      describe '#report_form' do
        it 'returns 200' do
          get :report_form, structure_id: participation_request.structure.slug,
                         id: participation_request.token
          expect(response.status).to eq 200
        end
      end
    end
    context 'user is not signed in' do
      describe '#edit' do
        it 'returns 200' do
          get :edit, structure_id: participation_request.structure.slug,
                     id: participation_request.token
          expect(response).to be_success
        end
      end
    end
  end
  context 'User is not signed in' do
    describe '#edit' do
      it 'returns 200' do
        get :edit, structure_id: participation_request.structure.slug,
                       id: participation_request.token
        expect(response.status).to eq 200
      end
      it 'redirects if id was given' do
        get :edit, structure_id: participation_request.structure.slug,
                   id: participation_request.id
        expect(response).to be_redirect
      end
    end
    describe '#accept_form' do
      it 'returns 200' do
        get :accept_form, structure_id: participation_request.structure.slug,
                       id: participation_request.token
        expect(response.status).to eq 200
      end
    end
    describe '#cancel_form' do
      it 'returns 200' do
        get :cancel_form, structure_id: participation_request.structure.slug,
                       id: participation_request.token
        expect(response.status).to eq 200
      end
    end
    describe '#report_form' do
      it 'returns 200' do
        get :report_form, structure_id: participation_request.structure.slug,
                       id: participation_request.token
        expect(response.status).to eq 200
      end
    end
    describe '#accept' do
      it 'accepts and redirect' do
        patch :accept, structure_id: participation_request.structure.slug,
                       id: participation_request.token,
                        participation_request: {
                          message: { body: 'Lorem' }
                        }
        expect(assigns(:participation_request).accepted?).to be_truthy
        expect(response).to be_redirect
      end
    end
    describe '#modify_date' do
      it 'modify_date and redirect' do
        patch :modify_date, structure_id: participation_request.structure.slug,
                       id: participation_request.token,
                        participation_request: {
                          message: { body: 'Lorem' }
                        }
        expect(assigns(:participation_request).pending?).to be_truthy
        expect(response).to be_redirect
      end
    end
    describe '#discuss' do
      it 'discuss and redirect' do
        patch :discuss, structure_id: participation_request.structure.slug,
                       id: participation_request.token,
                        participation_request: {
                          message: { body: 'Lorem' }
                        }
        expect(assigns(:participation_request).pending?).to be_truthy
        expect(response).to be_redirect
      end
    end
    describe '#cancel' do
      it 'cancel and redirect' do
        patch :cancel, structure_id: participation_request.structure.slug,
                       id: participation_request.token,
                        participation_request: {
                          message: { body: 'Lorem' }
                        }
        expect(assigns(:participation_request).canceled?).to be_truthy
        expect(response).to be_redirect
      end
    end
    describe '#report' do
      it 'reports and redirect ' do
        patch :report, structure_id: participation_request.structure.slug,
                       id: participation_request.token,
                        participation_request: {
                        }
        expect(response).to be_redirect
      end
    end
  end
end
