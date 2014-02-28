require 'spec_helper'

describe Users::ParticipationsController do

  let(:user)     { FactoryGirl.create(:user) }
  let(:planning) { FactoryGirl.create(:planning) }

  before do
    sign_in user
  end

  describe :destroy do
    it 'cancel the participation' do
      participation = planning.participations.create(user: user)
      delete :destroy, user_id: user.id, id: participation.id
      response.should be_redirect
      assigns(:participation).canceled?.should be_true
    end
  end

end
