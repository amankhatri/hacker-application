
#we are required to program speaker controller to display the details of the speaker 
#on the speaker page. THe page should contain a photo of the speaker, name of the 
#speaker, organization with which he is affilated to, biography, the topic on which
#he is speaking, and the picture pertaining to the topic, and topic description.
#Photograph
#Name
#Organization
#Biography
#Topic
#Topic Picture
#Topic Description

require 'awesome_print'

class SpeakersController < ApplicationController

  def index
    puts session[:meeting_id]
    @speakers = Speaker.find(:all, :conditions => 'display_name != "" AND meeting_id = ' + session[:meeting_id] )
    respond_to do |format|
      format.html
      format.json {render json: @speakers}
    end
  end

  def show
    @speakers = Speaker.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @speakers }
    end

  end

  def new
    @speakers = Speaker.new
    @speakers.meeting_id = session[:meeting_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @speakers }
    end

  end

  def create
    @speakers = Speaker.new(params[:speakers])
    @speakers.meeting_id = session[:meeting_id]

    respond_to do |format|
      if @speakers.save
        format.html { redirect_to @speakers, notice: 'Speaker was successfully created.' }
        format.json { render json: @speakers, status: :created, location: @speakers }
      else
        format.html { render action: "new" }
        format.json { render json: @speakers.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @speakers = Speaker.find(params[:id])

  end

  def destroy
    @speakers = Speaker.find(params[:id])
    @speakers.destroy

    respond_to do |format|
      format.html { redirect_to @speakers }
      format.json { head :no_content }
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

  def update
    @speakers = Speaker.find(params[:id])
#    ap @speakers
    respond_to do |format|
      if @speakers.update_attributes(params[:speakers])
#        ap 'made it here!'
#        ap @speakers
#        ap params[:speakers]
#        s = Speaker.find(4)
#        ap s
        format.html { redirect_to @speakers, notice: 'Speaker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @speakers.errors, status: :unprocessable_entity }
      end
    end
  end
end
