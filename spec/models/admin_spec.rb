# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin do
  subject {admin}
  context :admin do
    let(:admin) { FactoryGirl.build(:admin) }

    it {should be_valid}
    it 'should not be super_admin' do
      admin.super_admin.should == false
    end
  end
end
