require 'rails_helper'

RSpec.describe Sponsorship, :type => :model do
  let (:user)         { FactoryGirl.create(:user) }
  let (:sponsored_user) { FactoryGirl.create(:user_redux) }
end
