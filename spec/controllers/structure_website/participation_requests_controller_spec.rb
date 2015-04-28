# -*- encoding : utf-8 -*-
require 'rails_helper'

describe StructureWebsite::ParticipationRequestsController, type: :controller do

  let (:participation_request) { FactoryGirl.create(:participation_request) }
  let (:structure)             { FactoryGirl.create(:structure) }
  let (:user)                  { FactoryGirl.create(:user) }
  let (:planning)              { FactoryGirl.create(:planning) }

  before(:each) do
    @request.host = "#{participation_request.structure.slug}.example.com"
  end

  describe '#create' do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end
    context 'when resource is found' do
      it 'creates a participation_request' do
        post :create, { participation_request: {
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

      it 'creates a user' do
        post :create, { participation_request: {
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
        expect(assigns(:user)).to be_persisted
        expect(assigns(:user).email).to eq 'lorem@ipsum.com'
        expect(assigns(:user).phone_number).to eq '021402104'
        expect(assigns(:user).first_name).to eq 'Lorem'
      end

      it 'updates existing user' do
        post :create, { participation_request: {
                          structure_id: structure.id,
                          message: {
                            body: 'Lorem'
                          },
                          user: {
                            phone_number: '021402104',
                            name: 'Lorem',
                            email: user.email
                          }
                        }
        }
        expect(assigns(:user).id).to eq user.id
        expect(assigns(:user).phone_number).to eq '021402104'
        expect(assigns(:user).first_name).to eq 'Lorem'
      end
    end
  end

  describe '#show' do
    it 'finds the participation_request' do
      get :show, id: participation_request.token
      expect(response.status).to eq 200
    end

    it 'redirects because only ID was given' do
      get :show, id: participation_request.id
      expect(response.status).to eq 302
    end
  end

end