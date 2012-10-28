class Speaker < ActiveRecord::Base
belongs_to :meeting
belongs_to :state
belongs_to :country

# image/too large is caught by validate method below                      
validates_format_of   :mime_type,
                      :with       =>  %r{\A(image\/(gif|jpg|jpeg|pjpeg|png|x-png|too_large))?\z}i,
                      :message    =>  "File must be a jpg, jpeg, gif, or png image."                 

validates_format_of   :speaker_url,
                      :with       =>  %r{\A(\A(http|https|ftp)\://([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)?((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.[a-zA-Z]{2,4})(\:[0-9]+)?(/[^/][a-zA-Z0-9\.\,\?\'\\/\+&amp;%\$#\=~_\-@]*)*$)?\z}i,
                      :message    =>  " is not a valid url. (missing http:// or similar prefix?)"

validates_format_of   :email,                        
                      :with       => %r{\A([_a-zA-Z0-9\-!+]+(\.[_a-zA-Z0-9\-!+]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name)))?\z}i,
                      :message    => " must be valid."                            

validates_presence_of :display_name,
                      :message    =>  " is required when first and/or last name given",
                      :if => Proc.new { |s| !s.first_name.blank? or !s.last_name.blank? }

validates_length_of   :topic, :maximum => 120, :allow_nil => true, :message=>" has a maximum length of 120 characters."
validates_length_of   :organization, :maximum => 256, :allow_nil => true, :message=>" has a maximum length of 256 characters."
validates_length_of   :biography, :maximum => 8192, :allow_nil => true, :message=>" has a maximum length of 8192 characters."
validates_length_of   :city, :maximum => 128, :allow_nil => true, :message=>" has a maximum length of 128 characters."

validates_length_of   :first_name, :maximum => 64, :allow_nil => true, :message=>" has a maximum length of 64 characters."
validates_length_of   :middle_name, :maximum => 64, :allow_nil => true, :message=>" has a maximum length of 64 characters."
validates_length_of   :last_name, :maximum => 64, :allow_nil => true, :message=>" has a maximum length of 64 characters."
validates_length_of   :suffix, :maximum => 32, :allow_nil => true, :message=>" has a maximum length of 32 characters."
validates_length_of   :prefix, :maximum => 16, :allow_nil => true, :message=>" has a maximum length of 16 characters."
validates_length_of   :speaker_url, :maximum => 512, :allow_nil => true, :message=>" has a maximum length of 512 characters."
validates_length_of   :display_name, :maximum => 256, :allow_nil => true, :message=>" has a maximum length of 256 characters."
validates_length_of   :topic_description, :maximum => 8192, :allow_nil => true, :message=>" has a maximum length of 8192 characters."
validates_length_of   :email, :maximum => 128, :allow_nil => true, :message=>" has a maximum length of 128 characters."


public
  def has_info?()
  
    fields_to_check = [ :display_name, :topic ];
  
    result =  false
  
    fields_to_check.each do |f|
      result = true if ( self[f] and not self[f].blank? )
    end
    result
  end

  def validate
    errors.add(:picture, "too large")   if self.mime_type == 'image/too_large'
  end

end
