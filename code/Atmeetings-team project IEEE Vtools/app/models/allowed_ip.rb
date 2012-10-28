class AllowedIp < ActiveRecord::Base
  
  validates_presence_of :address
  validates_uniqueness_of :address  
  validates_format_of :address,
                      :with => /\A(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?\z/,
                      :message => 'does not appear to be an IP address.'
  
end
