class HomePageController < ApplicationController
  # All actions in this controller require ADMIN role or volunteer role
  before_filter :authorize
  
  # GET /home_page
  def index
  end
end
