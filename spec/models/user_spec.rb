# -*- encoding : utf-8 -*-
require 'spec_helper'

describe User do
  context :active do
    it 'should not have password' do
      user = User.new name: 'Lorem', email: 'random@email.com'
      user.password.should be_nil
      user.active?.should be_false
    end
  end
end
