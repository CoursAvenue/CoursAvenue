require "rails_helper"

describe Admin::SubjectsController do
  include Devise::TestHelpers

  let(:admin) { FactoryGirl.create(:super_admin) }

  before do
    Rails.cache.clear
    sign_in admin
  end

  it { should use_before_action(:authenticate_pro_super_admin!) }

  describe '#index' do
  end
end
