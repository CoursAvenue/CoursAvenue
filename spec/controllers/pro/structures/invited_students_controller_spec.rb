# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Pro::Structures::InvitedStudentsController do

  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  describe 'index' do
    it 'returns 200' do
      get :index, structure_id: admin.structure.slug
      expect(response).to be_success
    end
  end

  describe 'new' do
    it 'returns 200' do
      get :new, structure_id: admin.structure.slug
      expect(response).to be_success
    end
  end

  describe 'bulk_create' do
    it 'returns 200' do
      post :bulk_create, structure_id: admin.structure.slug, emails: "person#{rand.to_s.gsub('.', '')}@example.com", text: 'lorem'
      expect(response).to be_redirect
    end
    it 'creates an invited_student' do
      initial_length = admin.structure.invited_students.count
      post :bulk_create_jpo, structure_id: admin.structure.slug, emails: "person#{rand.to_s.gsub('.', '')}@example.com", text: 'lorem'
      expect(admin.structure.invited_students.count).to eq (initial_length + 1)
    end
  end

  describe 'bulk_create_jpo' do
    it 'returns 200' do
      post :bulk_create_jpo, structure_id: admin.structure.slug, emails: "person#{rand.to_s.gsub('.', '')}@example.com", text: 'lorem'
      expect(response).to be_redirect
    end

    it 'creates an invited_student for jpo' do
      initial_length = admin.structure.invited_students.for_jpo.count
      post :bulk_create_jpo, structure_id: admin.structure.slug, emails: "person#{rand.to_s.gsub('.', '')}@example.com", text: 'lorem'
      expect(admin.structure.invited_students.for_jpo.count).to eq (initial_length + 1)
    end
  end
end
