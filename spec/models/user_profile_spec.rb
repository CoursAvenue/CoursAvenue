# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserProfile do

  describe '#associate_to_user' do
    let(:structure) { FactoryGirl.create(:structure) }
    let(:user)      { FactoryGirl.create(:user) }

    it 'associates to existing user if exists' do
      user_profile = structure.user_profiles.build(email: user.email)
      user_profile.send(:associate_to_user)
      user_profile.user.should eq user
    end

    it 'creates user if does not exists' do
      user_profile = structure.user_profiles.build(email: 'does-not@exists.com')
      user_profile.send(:associate_to_user)
      user_profile.user.persisted?.should be_true
    end
  end

  describe '#full_name' do
    it 'contains the first_name' do
      user_profile = UserProfile.new first_name: 'First Name', last_name: 'Last Name'
      expect(user_profile.full_name).to include 'First Name'
    end
    it 'contains the last_name' do
      user_profile = UserProfile.new first_name: 'First Name', last_name: 'Last Name'
      expect(user_profile.full_name).to include 'Last Name'
    end
  end
end
