# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin do
  context 'full_name' do
    it 'should display firstname and lastname' do
      admin             = FactoryGirl.create(:admin_user)
      full_name          = admin.full_name
      expected_full_name = "#{admin.firstname} #{admin.lastname}"
      expect(full_name).to eq(expected_full_name)
    end
  end
end
