require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  #check for successful login
  test "should login" do
  	frankie = LdapUser.find(1)
    post :create, name: frankie.user_name, password: 'frankie'
    assert_redirected_to "/select"
    assert_equal frankie.id, session[:user_id]
  end
 
  #make sure incorrect credentials fail
  test "should fail login" do
    frankie = LdapUser.find(1)
    post :create, name: frankie.user_name, password: 'wrong'
    assert_redirected_to login_url
  end 

  #check if logout correctly
  test "should logout" do
    delete :destroy
    assert_redirected_to login_url
  end

end
