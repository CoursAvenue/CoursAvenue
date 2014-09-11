# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Users::InvitedUsersController do

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

  describe 'bulk_create_jpo' do
    it 'returns 200' do
      post :bulk_create_jpo, user_id: user.id, emails: "person#{rand.to_s.gsub('.', '')}@example.com", text: 'lorem'
      expect(response).to be_redirect
    end

    it 'creates an invited_student for jpo' do
      initial_length = user.invited_users.for_jpo.count
      post :bulk_create_jpo, user_id: user.id, emails: "person#{rand.to_s.gsub('.', '')}@example.com", text: 'lorem'
      expect(user.invited_users.for_jpo.count).to eq (initial_length + 1)
    end
  end
end
