require "rails_helper"

describe Pro::Structures::CoursesController do
  include Devise::TestHelpers
  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  # describe "GET #index" do
  # end
end
