require 'test_helper'

class HomePageControllerTest < ActionController::TestCase
  #move past the login page
  setup do
  	session[:meeting_id] = '1'
  	session[:user_id] = '1'
  end
  
  #test the button links successfully gets the correct pages   
  test "should get meeting pages" do
    get :index
    assert_response :success
  end  
end