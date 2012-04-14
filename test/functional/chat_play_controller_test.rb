require 'test_helper'

class ChatPlayControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get pricing" do
    get :pricing
    assert_response :success
  end

  test "should get profiting" do
    get :profiting
    assert_response :success
  end

  test "should get signup" do
    get :signup
    assert_response :success
  end

  test "should get contact_us" do
    get :contact_us
    assert_response :success
  end

end
