require 'tzinfo' #uncomment this line once you have installled the tzinfo gem file

class MeetingRegistration < ActiveRecord::Base
  belongs_to :ldap_user
  belongs_to :meeting
  belongs_to :country
  belongs_to :state
  belongs_to :registration_fee_invoice
  belongs_to :registration_fee_level
  
                          

  validates_presence_of :first_name, :message=> "cannot be null" 
  validates_presence_of :last_name,  :message=> "cannot be null"
  validates_presence_of :city,  :message=> "cannot be null"
  validates_presence_of :email,  :message=> "cannot be null"
  validates_presence_of :country, :message => "cannot be null"
  validates_presence_of :state, :message => "cannot be null"
  
  validates_format_of   :email,                        
                        :with       => %r{\A([_a-zA-Z0-9-]+(\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name)))?\z}i,
                        :message    => " is not formatted properly"  
                      
  validates_length_of   :first_name, :maximum => 32, :message => " cannot be longer than 32 characters"
  validates_length_of   :last_name, :maximum => 32, :message => " cannot be longer than 32 characters"
  validates_length_of   :city, :maximum => 64, :message => " cannot be longer than 64 characters"
  validates_length_of   :address1, :maximum => 64, :allow_nil => true, :message => " cannot be longer than 64 characters"
  validates_length_of   :address2, :maximum => 64, :allow_nil => true, :message => " cannot be longer than 64 characters"
  validates_length_of   :postal_code, :maximum => 16, :allow_nil => true, :message => " cannot be longer than 16 characters"
  validates_length_of   :special_requests, :maximum =>500, :allow_nil => true, :message => " cannot be longer than 500 characters"
  
  def before_create
    a = MeetingRegistration.find(:all, :conditions=> ["first_name=? and last_name=? and email=? and meeting_id=?", self.first_name, self.last_name, self.email, self.meeting_id])
    errors.add(:first_name, ": You have already been registered for this meeting.") if a.length > 0       
  end

  def no_charge?
    return self.amount && self.amount.to_f == 0.0
  end

end
