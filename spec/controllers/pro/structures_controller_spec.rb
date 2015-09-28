require 'rails_helper'

describe Pro::StructuresController do
  include Devise::TestHelpers

  describe 'PATCH #enable' do
    let(:structure) { FactoryGirl.create(:structure_with_admin, :disabled) }
    let!(:admin) { structure.admin }

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
