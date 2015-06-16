require 'rails_helper'

describe Pro::StructuresController do
  include Devise::TestHelpers

  let!(:admin) { FactoryGirl.create(:super_admin) }

  before do
    sign_in admin
  end

  describe 'POST #import' do
    context 'when the file is valid' do
      let(:file)         { fixture_file_upload('files/structures.csv', 'text/csv')}
      let(:valid_params) { { structure_import: { file: file } } }

      it 'redirects with a success flash message' do
        post :import, valid_params
        expect(response).to redirect_to(pro_structures_path)
        expect(flash[:notice]).to be_present
      end

      it 'creates new structures' do
        expect { post :import, valid_params }.
          to change { Structure.count }.by(1)
      end
    end

    context 'when the file is invalid' do
      let(:file)           { fixture_file_upload('files/structures.txt', 'text/csv')}
      let(:invalid_params) { { structure_import: { file: file } } }

      it "doensn't create new structures" do
        expect { post :import, invalid_params }.
          to_not change { Structure.count }
      end

      it 'redirects with a error flash message' do
        post :import, invalid_params
        expect(response).to redirect_to(pro_structures_path)
        expect(flash[:error]).to be_present
      end
    end
  end
end
