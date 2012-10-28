class SelectMeetingController < ApplicationController
  # All actions in this controller require ADMIN role or volunteer role
  before_filter :authorize
  skip_before_filter :meeting_selected
  
  layout 'login'
  # GET /select_meeting
  def index
    #geting the section_id from the session user
    section_id = (LdapUser.find(session[:user_id])).section_id
    #selecting meetings based on the section_id (search was done by joining the specific_organization with Meeting)
    @meetings = Meeting.joins(:specific_organization).where(:specific_organizations => {section_id: section_id}).order("start_time DESC")
    @descriptive_meetings=[]
    @meetings.each do |meeting| 
      #creating the select_tag_option
      @descriptive_meetings << ["#{meeting.title} - #{meeting.city} - #{meeting.description}".truncate(45),meeting.id] 
    end    
  end
   
  
  def create
    #saving the selected meeting
    session[:meeting_id] = params[:value]
    redirect_to home_url
  end
  
end
