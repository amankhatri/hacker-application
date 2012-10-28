
require 'test_helper'

class CurrentMeetingsControllerTest < ActionController::TestCase
  setup do
    session[:meeting_id] = '1'
    session[:user_id] = '1'
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:meetings)
  end

end
