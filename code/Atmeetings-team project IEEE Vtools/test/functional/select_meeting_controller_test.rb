require 'test_helper'
 
class SelectMeetingControllerTest < ActionController::TestCase
  #move past login
  setup do
  	session[:meeting_id] = '1'
  	session[:user_id] = '1'		
  end
	
  test "should get index" do
	get :index
	assert_response :success
  end
	
  #check if meeting was selected
  test "should create meeting" do
	post :create, select_meeting: {
	meeting_id: '1'		
    }
    assert_redirected_to home_url
  end	
end   