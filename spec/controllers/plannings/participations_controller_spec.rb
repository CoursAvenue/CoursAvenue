require 'spec_helper'

describe Pro::Plannings::ParticipationsController do

  describe :create do
    let(:user)     { FactoryGirl.create(:user) }
    let(:planning) { FactoryGirl.create(:planning) }

    before do
      sign_in user
    end
    it 'saves the participation' do
      post :create, planning_id: planning.id
      response.should be_redirect
      # assigns(:comment).user.email.should eq 'random@test.com'
    end
  end

end
