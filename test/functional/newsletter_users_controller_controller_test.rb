require 'test_helper'

class NewsletterUsersControllerControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

end
