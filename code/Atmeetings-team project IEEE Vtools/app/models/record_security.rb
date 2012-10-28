# Provides the beginnings of centralization for record-level security, created in
# response to this functionality being duplicated (from application_controller into
# meeting_report_helper and meeting_view_helper).

# The models where record-level security is supported are listed at the top of
# the class, and public static accessors are provided for where these record types
# need to be specified (like so: RecordSecurity.RECORD_TYPES_REPORT).

class RecordSecurity

  RECORD_TYPES_MEETING = "meeting"
  RECORD_TYPES_REPORT = "meeting_report"
  RECORD_TYPES_REGISTRATION = "meeting_registration"

#  @RECORD_TYPES_MEETING  ||= "meeting"
#  @RECORD_TYPES_REPORT ||= "meeting_report"
#  @RECORD_TYPES_REGISTRATION ||= "meeting_registration"
#
#  class << self
#    attr_reader :RECORD_TYPES_MEETING, :RECORD_TYPES_REPORT, :RECORD_TYPES_REGISTRATION
#  end
  
  # General validation methods

  # True if the currently logged in user has access to the specified record, false if not
  # 'state' is a hash that can/should have: :session, :request, :params, :flash
  # 'record_type' should be one of the RECORD_TYPES_* values from this class
  def self.validate_section_role(state, record_type, record_id, item=nil)

    session = state[:session]

    unless session[:ldap_user]
      # If there's no logged in user in the session, then fail
      return false
    end

    return self.has_meeting_modify_role?(state, record_type, record_id, item)

  end

  # True if the currently logged in user has access to the specified record, false if not
  # 'state' is a hash that can/should have: :session, :request, :params, :flash
  # 'record_type' should be one of the RECORD_TYPES_* values from this class
  def self.has_meeting_modify_role?(state, record_type, record_id, item=nil)

    session = state[:session]

    # This method is designed so that as soon as a definitive answer can be made as to whether the current
    #  user/request has the appropriate permissions, then that answer is returned.  If no definitive answer
    #  can be determined (for whatever reason, ie. if we don't have what we need to determine the answer),
    #  then false will be returned at the end of the method.

    # First we can check the user role in the session, it could give us an easy pass or fail
    if (! session[:user_role])
      return false
    elsif (session[:user_role] == ADMIN)
      return true
    end

    # If we get here, then we need to try a more granular security check

    # If no item is specified, then we'll try to get one (the possible values for 'record_type'
    #  are specified as contstants at the top of this file)
    if (!item)
      case record_type
      when RECORD_TYPES_MEETING
        item = Meeting.find(record_id)
      when RECORD_TYPES_REPORT
        item = MeetingReport.find(record_id)
      when RECORD_TYPES_REGISTRATION
        item = MeetingRegistration.find(record_id)
      else
        # This is a strict implementation, where if the value that is passed for 'record_type' is
        #  not recognized, then an exception is thrown.  This could be commented out, and the result
        #  of the 'record_type' not being recognized would just be a failed security check.
        throw "The value '" + record_type + "' is not valid"
      end
    end

    # If we can do the security check, we should now have an item - it could be any of the types
    #  that are defined above
    if (item)

      the_section = nil
      the_region = nil

      if (item.respond_to?(:specific_organization))
        # If we can directly access specific org
        the_section = item.specific_organization.section.id
        the_region = item.specific_organization.section.region.id
      elsif (item.respond_to?(:meeting))
        # Otherwise we can look to see if the item is directly associated with a Meeting
        the_section = item.meeting.specific_organization.section.id
        the_region = item.meeting.specific_organization.section.region.id
      end

      # If we have one (section or region), then we should have both - we may only need one
      #  to validate though
      if ((the_section) && (the_region))
        if ((the_section == session[:sectionID].to_i) && (session[:user_role] == SSECTIONVOL))
          return true
        elsif ((the_region == session[:region_id]) && (session[:user_role] == SREGIONVOL))
          return true
        end
      end

    end

    # If we get here, then we haven't been able to verify the user having meeting modify role,
    #  so default to returning false and failing security check
    return false
  end

  # Meeting report validations

  # True if the currently logged-in user can update the meeting report specified
  # (non admins can only edit meeting_reports for one week from creation)
  # 'state' is a hash that can/should have: :session, :request, :params, :flash
  def self.validate_update_meeting_report_allowed(state, meeting_report)

    session = state[:session]

    if (session[:user_role] == ADMIN)
      # Admin is ok
      return true
    end

    # If not admin, then base it on the logged-in user having access to the
    # specified record and the report not being more than a week old
    return ( (meeting_report.created_on > Time.now.utc - 1.week) &&
             (self.has_meeting_modify_role?(state, RecordSecurity::RECORD_TYPES_REPORT, nil, meeting_report)) )

  end

  # True if the currently logged-in user can file a report for the meeting specified
  # 'state' is a hash that can/should have: :session, :request, :params, :flash
  def self.file_meeting_report_allowed?(state, meeting)

    session = state[:session]

    if session[:user_role] == nil || session[:user_role] <= MEMBERNOTVOL
      return false
    else
      mr = MeetingReport.find(:first, :conditions => [ "meeting_id = ?", meeting.id])
      if mr
        return self.validate_update_meeting_report_allowed(state, mr)
      else
        return true
      end
    end
  end


end