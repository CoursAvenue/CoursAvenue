# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Users::InvitedUsersController do
  include Devise::TestHelpers

  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
  end

  describe 'index' do
    it 'returns 200' do
      get :index, user_id: user.id
      expect(response).to be_success
    end
  end

  describe 'new' do
    it 'returns 200' do
      get :new, user_id: user.id
      expect(response).to be_success
    end
  end

  describe 'bulk_create' do
    it 'returns 200' do
      post :bulk_create, user_id: user.id, emails: 'lazd@cazd.com', text: 'lorem'
      expect(response).to be_redirect
    end
  end
end
