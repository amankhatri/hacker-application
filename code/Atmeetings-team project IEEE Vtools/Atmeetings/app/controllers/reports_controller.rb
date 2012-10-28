class ReportsController < ApplicationController
  
  # GET /reports/1
  # GET /reports/1.json
  def show
    @report = Report.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
    end
  end

  # GET /reports/new
  # GET /reports/new.json
  def new
    meeting=Meeting.find(session[:meeting_id])
    @report = MeetingReport.new
    @report.title = meeting.title
    @meeting=Meeting.find(session[:meeting_id])
    @total_count = 0
    @ieee_count=0
    @guest_count=0
    # finding the attendees
    @attendees = MeetingRegistration.where(:meeting_id => session[:meeting_id]).all
    @attendees.each do |attendee| 
      if attendee.present == true
        @total_count+=1
        if attendee.member_number == nil 
          @guest_count+=1
        end
      end
    end
    @ieee_count= @total_count - @guest_count
    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report }
    end
  end

  #TODO: let the user edit the report, for now they only get a link to vtools.meeting to edit the report
  # GET /reports/1/edit
  def edit
    @report = Report.find(params[:id])
  end

  # POST /reports
  # POST /reports.json
  def create
  
    @meeting=Meeting.find(session[:meeting_id])
    #calleng the create_new method which create a report pre-filled with the some attributes
    @report = MeetingReport.create_new(@meeting)
    @report.title = @meeting.title
    @total_count = 0
    @ieee_count=0
    @guest_count=0
    #looking for attendees
    @attendees = MeetingRegistration.where(:meeting_id => session[:meeting_id]).all
    #checking if the attrndee is a guest or IEEE member
    @attendees.each do |attendee| 
      if attendee.present == true
          @total_count+=1
       if attendee.member_number == nil 
          @guest_count+=1
       end
      end
    end
    
    @ieee_count= @total_count - @guest_count
    @report.guests_attending = @guest_count
    @report.ieee_attending = @ieee_count 
    @report.submitter = LdapUser.find(session[:user_id]).display_name || ''
    
    # ADDED FOR L31 REPORT VIEW
    @report.submitter_email = LdapUser.find(session[:user_id]).email
    @report.submitter_ip = request.env['REMOTE_ADDR']
    # END ADD FOR L31 REPORT VIEW
    
    #TODO: send an email to the user for verification 
    #
    
    respond_to do |format|
      if @report.save
        format.html { redirect_to home_url, notice: 'Report was successfully created.' }
        format.json { render json: @report, status: :created, location: @report }
      else
        format.html { render action: "new" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reports/1
  # PUT /reports/1.json
  def update
    @report = Report.find(params[:id])

    respond_to do |format|
      if @report.update_attributes(params[:report])
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report = Report.find(params[:id])
    @report.destroy

    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end
end
