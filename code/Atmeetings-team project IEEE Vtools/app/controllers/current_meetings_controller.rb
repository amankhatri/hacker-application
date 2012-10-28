class CurrentMeetingsController < ApplicationController
  # GET /current_meetings
  # GET /current_meetings.json
  # @speakers = Speaker.find(:all, :conditions => "display_name != '' AND meeting_id =" + session[:meeting_id] ).uniq{|speaker| speaker.display_name}
  def index
    @speakers = Speaker.find(:all, :conditions => "display_name != '' AND meeting_id =" + session[:meeting_id] )
    @meetings = Meeting.find_by_id(session[:meeting_id]) 
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @meetings }
    end
  end

   def photograph
    @speakers = Speaker.find(params[:id])
    if not @speakers.mime_type == ''
      send_data @speakers.photograph, :filename => "nofilename", :type => @speakers.mime_type, :disposition => "inline"
    else
      send_data "<!--nothing-->", :disposition => "inline"
    end
  end
end
