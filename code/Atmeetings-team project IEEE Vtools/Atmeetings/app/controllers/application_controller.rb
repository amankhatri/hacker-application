class ApplicationController < ActionController::Base
  # All actions in this controller require ADMIN role or volunteer role
  protect_from_forgery
  before_filter :authorize
  before_filter :meeting_selected

  protected
  #A before_filter used in every controller
  def authorize
    unless LdapUser.find_by_id(session[:user_id])
      redirect_to login_url, notice: "Please log in"
    end
  end
  
  # A before_filter to ensure a meeting is selected
  def meeting_selected
    unless Meeting.find_by_id(session[:meeting_id])
      redirect_to "/select", notice: "Please select a meeting"
    end
  end
  
end
