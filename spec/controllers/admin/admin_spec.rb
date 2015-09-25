require 'rails_helper'

describe Admin::AdminController do
  include Devise::TestHelpers

  let(:admin) { FactoryGirl.create(:super_admin) }

  before do
    sign_in admin
  end

  controller(Admin::AdminController) do
    def index
      render nothing: true
    end
  end

  it { should use_before_action(:authenticate_pro_super_admin!) }
end
