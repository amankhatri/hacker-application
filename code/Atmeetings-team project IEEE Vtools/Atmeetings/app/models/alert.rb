class Alert < ActiveRecord::Base

    
  belongs_to :alert_type
  belongs_to :ldap_user
  belongs_to :meeting
  validates_presence_of :email_address, :hours_before, :alert_type_id
  validates_each :meeting_id, :alert_type_id, :ldap_user_id do |record, attr, value|
    if value == 0
      record.errors.add(attr, ["::No connectivity, value is ?", value] )
    end
  end
end
