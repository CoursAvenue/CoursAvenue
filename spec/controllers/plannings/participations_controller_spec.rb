require 'spec_helper'

describe Plannings::ParticipationsController do

  let(:user)     { FactoryGirl.create(:user) }
  let(:planning) { FactoryGirl.create(:planning) }

  before do
    sign_in user
  end

  describe 'create' do

    it 'saves the participation' do
      post :create, planning_id: planning.id, participation: { invited_friends: {} }

      expect(response).to have_http_status(:success)
      expect (assigns(:participation)).to be_persisted
      expect ((assigns(:planning)).participations.count).to eq(1)
    end
  end
end
