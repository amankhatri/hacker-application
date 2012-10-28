
require 'test_helper'

class MeetingsControllerTest < ActionController::TestCase
   
  setup do
      session[:meeting_id] = '2'
      session[:user_id] = '1'
      @meetings = Meeting.find(2)
   end

   test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:meetings)
   end
    
   test "should show meetings" do
      get :show, id: @meetings
      assert_response :success
   end
   
   test "should get edit" do
      get :edit, id: @meetings
      assert_response :success
   end
    
  # test "should update meetings" do
  #   put :update, id: @meetings, meetings: @update
  #   assert_redirected_to meetings_path(assigns(:meetings))
  # end
 
   test "should destroy meetings" do
      assert_difference('Meeting.count', -1) do
      delete :destroy, id: @meetings
   end
  
      assert_redirected_to meetings_path
   end
  
   test 'should send update form data' do
      put :update, id: @meetings, meetings: @update
   end
end