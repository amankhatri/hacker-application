class SessionsController < ApplicationController
  #no filters needed for this controller
  skip_before_filter :authorize
  skip_before_filter :meeting_selected
  
  layout 'login'
  # POST /login
  def new
  end

  # GET /login
  def create
    #geting the user id from user
    user = LdapUser.find_by_user_name(params[:name])
    
    #checking the user passower through a method in LdapUser
    if user and LdapUser.authenticate(user.user_name,params[:password])
      #checking the user role (63 and 511 is a volunteer, and 65535 is an admin)
      if user.role ==63 || user.role== 511
        session[:user_id] = user.id
        redirect_to "/select"
      elsif user.role==65535
        session[:user_id] = user.id
        #TODO: this should be changed to redirected to the select_meeting for admin
        redirect_to "/select"
      else
        redirect_to login_url, alert: "Limited Access"
      end    
    else
      redirect_to login_url, alert: "Invalid user/password combination"
    end
  end
  
  # DELETE /logout
  def destroy
    #loging out 
    session[:user_id] = nil
    redirect_to login_url, notice: "Logged out"
  end
end
