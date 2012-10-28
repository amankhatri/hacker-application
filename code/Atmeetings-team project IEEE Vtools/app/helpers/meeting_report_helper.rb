module MeetingReportHelper

# The following are now defined in the RecordSecurity model!
#  # NOTE THAT THESE ARE REPEATED IN controllers/application_controller!!! :-/
#  ROLE_RECORD_TYPE_MEETING = "meeting"
#  ROLE_RECORD_TYPE_MEETING_REPORT = "meeting_report"
#  ROLE_RECORD_TYPE_MEETING_REGISTRATION = "meeting_registration"

  def safe_text(s)
    if s.nil?
      return ""
    end
    if has_text?(s)
      s.gsub!("\t", " ")
      s.gsub("\n", " ")
    else
      ""
    end
  end

  # Whether the currently logged-in user can update the specified meeting_report
  def validate_update_meeting_report_allowed(meeting_report)

    return RecordSecurity.validate_update_meeting_report_allowed({:session=>session, :request=>request, :flash=>flash},
                                                                  meeting_report)
  end

  # Checks whether the currently logged-in user has access to the specified record
  def has_meeting_modify_role?(record_type, record_id, item=nil)

    return RecordSecurity.has_meeting_modify_role?({:session=>session, :request=>request, :flash=>flash},
                                                    record_type, record_id, item)
  end

  # Gets the display name to use for the meeting report specified
  def meeting_report_display_name(meeting_report)
    meeting_display_name(meeting_report)
  end

end
