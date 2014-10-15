require 'spec_helper'

describe SponsorshipsController do
  let (:user)           { FactoryGirl.create(:user) }
  let (:sponsored_user) { FactoryGirl.create(:user_redux) }
  let (:sponsorship)    { user.sponsorships.create(sponsored_user: sponsored_user) }


end
