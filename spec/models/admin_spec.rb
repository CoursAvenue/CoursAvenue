# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin do
  context 'full_name' do
    it 'should display firstname and lastname' do
      admin             = FactoryGirl.create(:admin)
      full_name          = admin.full_name
      expected_full_name = "#{admin.first_name} #{admin.last_name}"
      expect(full_name).to eq(expected_full_name)
    end
  end
end
