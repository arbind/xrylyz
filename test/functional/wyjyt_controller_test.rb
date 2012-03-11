require 'test_helper'

class WyjytControllerTest < ActionController::TestCase
  test "should get pusher_auth" do
    get :pusher_auth
    assert_response :success
  end

end
