class NewMember < ActionMailer::Base
  default from: " ieee-vtools@ieee.org"
  
  def new_member( registration, meeting, section)
    @registration = registration
    @meeting = meeting
    @section = section
    mail(:to => @registration.email, :subject => "IEEE Membership")
  end  
end
