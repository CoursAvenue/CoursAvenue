require 'rails_helper'

describe Pro::StructuresController do
  include Devise::TestHelpers

  describe 'POST #import' do

    let!(:admin) { FactoryGirl.create(:super_admin) }

    before do
      sign_in admin
    end

    context 'when the file is valid' do
      let(:file)         { fixture_file_upload('files/structures.csv', 'text/csv')}
      let(:valid_params) { { structure_import: { file: file } } }

      it 'redirects with a success flash message' do
        post :import, valid_params
        expect(response).to redirect_to(pro_structures_path)
        expect(flash[:notice]).to be_present
      end

      # it 'creates new structures' do
      #   expect { post :import, valid_params }.
      #     to change { Delayed::Job.count }.by(1)
      # end
    end

    context 'when the file is invalid' do
      let(:file)           { fixture_file_upload('files/structures.txt', 'text/csv')}
      let(:invalid_params) { { structure_import: { file: file } } }

      it "doensn't create new structures" do
        expect { post :import, invalid_params }.
          to_not change { Structure.count }
      end

      # it 'redirects with a error flash message' do
      #   post :import, invalid_params
      #   expect(response).to redirect_to(pro_structures_path)
      #   expect(flash[:error]).to be_present
      # end
    end
  end

  describe 'PATCH #enable' do
    let(:structure) { FactoryGirl.create(:structure, :disabled) }
    let!(:admin) { FactoryGirl.create(:admin, structure: structure) }

    before do
      sign_in admin
    end

    it 'enables the structure' do
      patch :enable, id: structure.slug
      structure.reload
      expect(structure.enabled?).to be_truthy
    end

    it 'redirects to the structure' do
      patch :enable, id: structure.slug
      expect(response).to redirect_to(pro_structure_path(structure))
    end
  end
end
