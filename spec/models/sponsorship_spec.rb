require 'spec_helper'

describe Sponsorship, :type => :model do
  let (:user)           { FactoryGirl.create(:user) }
  let (:sponsored_user) { FactoryGirl.create(:user_redux) }
end
