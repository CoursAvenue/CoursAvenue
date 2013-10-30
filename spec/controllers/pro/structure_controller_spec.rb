require "spec_helper"

describe Pro::StructuresController do
  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    it "'s forbidden" do
      get :index
      expect(response).to be_redirect
    end
  end
end
