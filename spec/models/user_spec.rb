# -*- encoding : utf-8 -*-
require 'spec_helper'

describe User do
  context :active do
    it 'should be active by default' do
      user = User.new name: 'Lorem', email: 'random@email.com'
      user.active.should be_true
    end
    it 'should not have password' do
      user = User.new name: 'Lorem', email: 'random@email.com'
      user.password.should be_nil
    end
  end
  context :inactive do
    it 'should have password' do
      user = User.new name: 'Lorem', email: 'random@email.com', active: false
      user.password.should_not be_nil
    end
  end
end
