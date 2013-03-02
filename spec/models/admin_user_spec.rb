# -*- encoding : utf-8 -*-
require 'spec_helper'

describe AdminUser do
  context 'fullname' do
    it 'should display firstname and lastname' do
      admin             = FactoryGirl.create(:admin_user)
      fullname          = admin.fullname
      expected_fullname = "#{admin.firstname} #{admin.lastname}"
      expect(fullname).to eq(expected_fullname)
    end
  end
end
