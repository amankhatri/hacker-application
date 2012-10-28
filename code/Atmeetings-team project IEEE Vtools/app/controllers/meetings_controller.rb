class MeetingsController < ApplicationController
  def index
    date = Time.now.utc
    @m2 = Meeting.find_by_id(session[:meeting_id])
    @meetings= Meeting.where(specific_organization_id: @m2.specific_organization_id.to_s).where('start_time > ?', date.to_s.gsub(/ UTC/,""))
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @meetings }
    end
  end
  
  def show
    @meetings = Meeting.find(params[:id])
    respond_to do |format|
    format.html # show.html.erb
    format.json { render json: @meetings }
    end
  end
  
  def search
    #TODO implement search function.
    puts params[:meeting_param]
  end
  
  def destroy
    @meetings = Meeting.find(params[:id])
    @meetings.destroy
    respond_to do |format|
    format.html { redirect_to meetings_url }
    format.json { head :no_content }
    end
  end
  
  def edit
    @meetings = Meeting.find(params[:id])
  end
  
 def update
    @meetings = Meeting.find(params[:id])
    respond_to do |format|
      if @meetings.update_attributes(params[:meeting])
        format.html { redirect_to @meetings, notice: 'Meeting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @meetings.errors, status: :unprocessable_entity }
      end
    end
  end

end
