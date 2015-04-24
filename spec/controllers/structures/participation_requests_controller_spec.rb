# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Structures::ParticipationRequestsController, type: :controller do
  include Devise::TestHelpers

  let (:participation_request) { FactoryGirl.create(:participation_request) }
  let (:structure)             { FactoryGirl.create(:structure) }
  let (:user)                  { FactoryGirl.create(:user) }
  let (:planning)              { FactoryGirl.create(:planning) }

  before do
    sign_in user
  end

  describe '#create' do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end
    context 'when resource is found' do
      it 'creates a participation_request' do
        post :create, { structure_id: participation_request.structure.slug,
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
