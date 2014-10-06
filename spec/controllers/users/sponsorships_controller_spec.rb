require 'spec_helper'

describe SponsorshipsController do
  let (:user)           { FactoryGirl.create(:user) }
  let (:sponsored_user) { FactoryGirl.create(:user_redux) }
  let (:sponsorship)    { user.sponsorships.create(sponsored_user: sponsored_user) }

  describe "GET #index" do
    it "loads all the sponsorships into @sponsorships" do
      get :index

      expect(assigns(@sponsorships)).to match_array([sponsorship])
    end
  end
end
