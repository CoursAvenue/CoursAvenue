require 'rails_helper'

RSpec.describe Pro::Structures::GiftCertificatesController, type: :controller do
  include Devise::TestHelpers

  let!(:structure)    { FactoryGirl.create(:structure_with_admin, :with_contact_email) }
  let!(:admin)        { structure.main_contact }

  before do
    sign_in admin
  end

  it { should use_before_action(:authenticate_pro_admin!) }
  it { should use_before_action(:set_structure) }
end
