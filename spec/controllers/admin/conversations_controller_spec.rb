require 'rails_helper'

describe Admin::ConversationsController do
  include Devise::TestHelpers
  let(:admin) { FactoryGirl.create(:super_admin) }
  before { sign_in admin }

  it do
    get :index
    expect(response).to have_http_status(:success)
  end
end
