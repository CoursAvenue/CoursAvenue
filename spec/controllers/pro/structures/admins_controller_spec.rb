require 'rails_helper'

describe Pro::Structures::AdminsController do
  include Devise::TestHelpers

  let(:structure) { FactoryGirl.create(:structure_with_admin) }
  let(:admin)     { structure.admin }

  before do
    sign_in admin
  end

  describe 'GET #show, #notifications' do
    [:show, :notifications].each do |route|
      it 'assigns the admin' do
        get route, id: admin.id, structure_id: structure.slug
        expect(assigns(:admin).id).to eq(admin.id)
      end

      it 'redirects to the edition page' do
        get route, id: admin.id, structure_id: structure.slug
        expect(response).to redirect_to(edit_pro_structure_admin_path(structure, admin))
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the admin' do
      get :edit, id: admin.id, structure_id: structure.slug
      expect(assigns(:admin).id).to eq(admin.id)
    end

    it 'renders the edit template' do
      get :edit, id: admin.id, structure_id: structure.slug
      expect(response).to render_template('edit')
    end
  end

  describe 'GET #modify_email' do
    it 'assigns the admin' do
      get :modify_email, id: admin.id, structure_id: structure.slug
      expect(assigns(:admin).id).to eq(admin.id)
    end

    it 'renders the modify_email template' do
      get :modify_email, id: admin.id, structure_id: structure.slug
      expect(response).to render_template('modify_email')
    end

    context 'when the request is xhr' do
      it 'renders without a template' do
        xhr :get, :modify_email, id: admin.id, structure_id: structure.slug
        expect(response).to_not render_with_layout('admin')
      end
    end
  end

  describe 'POST #create' do
    it 'creates a new admin' do
      expect { post :create, admin: valid_admin_params, structure_id: structure.slug }.
        to change { Admin.count }.by(1)
    end

    it 'associates it to the structure' do
      post :create, admin: valid_admin_params, structure_id: structure.slug
      expect(Admin.last.structure).to eq(structure)
    end

    context 'when the admin is invalid' do
      it 'renders the structure edition template' do
        post :create, admin: { email: Faker::Internet.email }, structure_id: structure.slug
        expect(response).to render_template('pro/structures/edit')
      end
    end

    context 'when the admin is valid' do
      it 'redirects to the structure path' do
        post :create, admin: valid_admin_params, structure_id: structure.slug
        expect(response).to redirect_to(structure_path(structure))
      end
    end
  end

  # describe 'PUT #update' do
  #   it 'updates the admin' do
  #     updated_email = Faker::Internet.email
  #
  #     expect {
  #       put :update, id: admin.id, structure_id: structure.slug,
  #           admin: valid_admin_update_params(updated_email)
  #     }.to change { admin.reload; admin.unconfirmed_email }.from(nil).to(updated_email)
  #   end
  #
  #   context 'when the admin is invalid' do
  #     it 'renders the edition template' do
  #       put :update, id: admin.id, structure_id: structure.slug,
  #         admin: { email: nil }
  #       expect(response).to render_template('pro/structures/admins/edit')
  #     end
  #   end
  #
  #   context 'when the admin is valid' do
  #     it 'redirects to the admin edition page' do
  #       put :update, id: admin.id, structure_id: structure.slug,
  #         admin: valid_admin_update_params
  #       expect(response).to redirect_to(edit_pro_structure_admin_path(structure, admin))
  #     end
  #   end
  # end

  def valid_admin_params
    { email: Faker::Internet.email, password: Faker::Internet.password }
  end

  def valid_admin_update_params(updated_email = Faker::Internet.password)
    { email: updated_email }
  end
end
