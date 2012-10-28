class AwardsDisplayController < ApplicationController
  
  
def index
    @awards = Award.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @awards }
    end
  end
  
end
