# -*- encoding : utf-8 -*-
require 'rails_helper'

describe UsersController do
  include Devise::TestHelpers

  describe 'invite_entourage_to_jpo_page' do
    it 'redirects if no email passed' do
      get :invite_entourage_to_jpo_page
      expect(response).to be_redirect
    end

    it 'returns 200' do
      get :invite_entourage_to_jpo_page, user_email: 'azdj@zapdojca.az'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #create' do
    let(:user_params) { stub_user_params }

    it 'creates a new user' do
      expect { get :create, user_params }.to change { User.count }.by(1)
    end

    it 'redirect to the root_path' do
      get :create, user_params

      expect(response).to be_redirect
    end
  end

  describe 'GET #show' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
    end

    it 'redirect to the edit path' do
      get :show, id: user.id

      expect(response).to redirect_to(edit_user_path(user))
    end
  end

end

def stub_user_params
  {
    user: {
      email: Faker::Internet.email,
      zip_code: '75005',
      subscription_from: 'newsletter'
    }
  }
end
