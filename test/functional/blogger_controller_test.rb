require 'test_helper'

class BloggerControllerTest < ActionController::TestCase
  test "should get blog" do
    get :blog
    assert_response :success
  end

end
