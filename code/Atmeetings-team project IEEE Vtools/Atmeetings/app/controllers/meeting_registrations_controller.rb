class MeetingRegistrationsController < ApplicationController
require 'ap'
   
  # GET /meeting_registrations/match
  def match
    #code for def match is taken from example by Professor David Green
    #sets up an array to store records that match the input of the drop list
    @meeting_registrations = []  
  #TODO fix so that if an user is checked in their name will not populate the drop list
    if (params[:email])
       @meeting_registrations = MeetingRegistration.where("meeting_id = ? and email like ? ", session[:meeting_id], params[:email] + '%').order(:email).limit(10)
    end
    
    respond_to do |format|
       format.html # show.html.erb
       format.json { render json: @meeting_registrations }       
    end    
  end
  
  #GET/meeting_registrations/new
  def new
    @meeting_registration = MeetingRegistration.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @meeting_registration }
    end
  end

  #POST /meeting_registrations/create
  def create
    # def create handles checking in attendees and initializing the email process for those 
    # non-members who are interested.
      #TODO fix me
    @meeting_registration = MeetingRegistration.new(params[:meeting_registration]) 
    #if the meeting id passed by the drop list is not blank
    if params[:meeting_registrations] != ""
      #TODO fix me
      @reg_id = params[:meeting_registrations]
      @meeting_registration = MeetingRegistration.new(params[:meeting_registration])
      
      @registration = MeetingRegistration.find(@reg_id)
      @meeting = @registration.meeting
      @section = @meeting.specific_organization.section
      
      #sets the present column in the Meeting Registrations tabel to 1 (true)  
      MeetingRegistration.update(@reg_id, :present => true)
      @meeting_registration = MeetingRegistration.new(params[:meeting_registration])

      #if the person is not a member and checks the box on _form    
      if params[:mem_inquiry] == "true" 
      #TODO mailer configuration points to local host 25
      # if the member number field in the Meeting Registration table is nill or blank
      # then an email is sent and the "interested" field in the Meeting Registration table is set to true
        if @registration.member_number == nil || @registration.member_number == ""  
          MeetingRegistration.update(@reg_id, :interested => true)
          #sends parameters to the mailer new_member.rb
          NewMember.new_member(@registration, @meeting, @section).deliver
        end  
      end
    end

    respond_to do |format|
      format.html { render action: "new" }
    end
  end
  
  def register
    
    #allows dynamic changing of link to register for the current meeting
    @id = session[:meeting_id]
    @web_address = "https://meetings.vtools.ieee.org/meeting_registration/register/" + session[:meeting_id]
    redirect_to(@web_address )

  end  
end
