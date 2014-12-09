# -*- encoding : utf-8 -*-
require 'rails_helper'

describe UsersController do

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

end
