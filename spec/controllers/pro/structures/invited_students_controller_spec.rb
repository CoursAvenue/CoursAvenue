# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Pro::Structures::InvitedStudentsController do

  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  describe :index do
    it 'returns 200' do
      get :index, structure_id: admin.structure.slug
      expect(response).to be_success
    end
  end

  describe :new do
    it 'returns 200' do
      get :new, structure_id: admin.structure.slug
      expect(response).to be_success
    end
  end

  describe :bulk_create do
    it 'returns 200' do
      post :bulk_create, structure_id: admin.structure.slug, emails: 'lazd@cazd.com', text: 'lorem'
      expect(response).to be_redirect
    end
  end

end
