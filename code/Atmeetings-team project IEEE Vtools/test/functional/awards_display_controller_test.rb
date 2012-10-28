require 'test_helper'

class AwardsDisplayControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = '1'
     @award = awards(:one)
   end
 
   test "should get index" do
     get :index
     assert_response :success
     assert_not_nil assigns(:awards)
   end

end
