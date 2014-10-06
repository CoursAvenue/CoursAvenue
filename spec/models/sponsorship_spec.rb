require 'rails_helper'

RSpec.describe Sponsorship, :type => :model do
  let (:user)         { FactoryGirl.create(:user) }
  let (:invited_user) { FactoryGirl.create(:user_redux) }
end
