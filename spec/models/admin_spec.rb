# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin do
  describe :factories do
    subject {admin}
    context :admin do
      let(:admin) { FactoryGirl.build(:admin) }

      it {should be_valid}
      it 'should not be super_admin' do
        admin.super_admin.should_be false
      end
    end
  end
end

