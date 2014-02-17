require 'spec_helper'

describe Plannings::ParticipationsController do

  let(:user)     { FactoryGirl.create(:user) }
  let(:planning) { FactoryGirl.create(:planning) }

  before do
    sign_in user
  end

  describe :create do

    it 'saves the participation' do
      post :create, planning_id: planning.id
      response.should be_redirect
      assigns(:participation).should be_persisted
      assigns(:planning).participations.count.should eq 1
    end
  end

  describe :destroy do
    it 'cancel the participation' do
      participation = planning.participations.create(user: user)
      delete :destroy, planning_id: planning.id, id: participation.id
      response.should be_redirect
      assigns(:participation).canceled?.should be_true
    end
  end

end
