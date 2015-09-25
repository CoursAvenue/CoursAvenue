require "rails_helper"

describe Pro::ProController do
  include Devise::TestHelpers

  let(:structure) { FactoryGirl.create(:structure_with_admin) }
  let(:admin)     { structure.admin }

  before do
    sign_in admin
  end

  controller(Pro::ProController) do
    def index
      render nothing: true
    end
  end

  it { should use_before_action(:authenticate_pro_admin!) }
end
