require 'rails_helper'

describe Admin::AdminController do
  include Devise::TestHelpers

  let(:admin) { FactoryGirl.create(:super_admin) }

  before { sign_in admin }

  controller(Admin::AdminController) do
    def index
      render nothing: true
    end
  end

  it { should use_before_action(:authenticate_pro_super_admin!) }
end
