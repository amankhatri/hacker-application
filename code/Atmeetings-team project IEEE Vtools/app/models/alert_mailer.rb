class AlertMailer < ActionMailer::Base
  helper :application

  require 'yaml';

  # The following 2 emails are used to notify meeting organizers when registrations are made,
  # (one for if special requests were involved and one without)
  def meeting_organizer_registrations_made(meeting, meeting_registrations, alert, apphost)
    subject = 'New IEEE vTools Reservation ('
    subject += meeting_registrations.length.to_s
    subject += ' registrant'
    subject += ((meeting_registrations.length == 1) ? "" : "s")
    subject += ')'
    @subject    = subject
    @body["meeting"] = meeting
    @body["meeting_registrations"] = meeting_registrations
    @recipients = alert.email_address
    @from       = YAML.load_file(File.join('config', 'email.yml'))["alert_from_address"] #'IEEE vTools.Meetings <no_reply@ieee.org>'
    @sent_on    = Time.now
    @content_type =  "text/html"
    @apphost = apphost
    #@headers    = {}
  end
  def meeting_organizer_registrations_made_special_requests(meeting, meeting_registrations, alert, apphost)
    subject = 'New IEEE vTools Reservation ('
    subject += meeting_registrations.length.to_s
    subject += ' registrant'
    subject += ((meeting_registrations.length == 1) ? "" : "s")
    subject += ') - Special requests made'
    @subject    = subject
    @body["meeting"] = meeting
    @body["meeting_registrations"] = meeting_registrations
    @recipients = alert.email_address
    @from       = YAML.load_file(File.join('config', 'email.yml'))["alert_from_address"] #'IEEE vTools.Meetings <no_reply@ieee.org>'
    @sent_on    = Time.now
    @content_type =  "text/html"
    @apphost = apphost
    #@headers    = {}
  end

  def meeting_creator(meeting, meeting_registrations, alert, apphost)
    @subject    = 'IEEE vTools Reservation Statistics'
    @body["meeting"] = meeting
    @body["meeting_registrations"] = meeting_registrations
    @recipients = alert.email_address
    @from       = YAML.load_file(File.join('config', 'email.yml'))["alert_from_address"] #'IEEE vTools.Meetings <no_reply@ieee.org>'
    @sent_on    = Time.now
    @content_type =  "text/html"
    @apphost = apphost
    #@headers    = {}
  end

  def small(meeting, alert)
    @subject    = 'IE3 Mtg Alrt'
    @body["meeting"] = meeting
    @recipients = alert.email_address
    @from       = YAML.load_file(File.join('config', 'email.yml'))["alert_from_address"] #'no_reply@ieee.org'
    @sent_on    = Time.now
    #@headers    = {}
  end

  def smallreport(meeting_report, alert)
    @subject    = 'IE3 L31 Report Submittal'
    @body["meeting_report"] = meeting_report
    @recipients = alert.email_address
    @from       = YAML.load_file(File.join('config', 'email.yml'))["alert_from_address"] #'no_reply@ieee.org' #IEEE vTools.Meetings <no_reply@ieee.org>'
    @sent_on    = Time.now
    @content_type =  "text/html"
    #@headers    = {}
  end

  # invoice param can be nil.
  def normal(invoice, meeting_registration, alert, apphost, ldap_user='')
    meeting = meeting_registration.meeting
    @subject    = 'IEEE vTools Reservation Confirmation'
    @body["invoice"] = invoice
    @body["meeting"] = meeting
    @body["meeting_registration"] = meeting_registration
    @body["ldap_user"] = ldap_user
    @recipients = alert.email_address
    @from       = YAML.load_file(File.join('config', 'email.yml'))["alert_from_address"] #'IEEE vTools.Meetings <no_reply@ieee.org>'
    @sent_on    = Time.now
    @apphost = apphost
    #@headers    = {}
  end

  def meeting_report_full(model, alert)

    subject = model.class.to_s + " Submitted"
    ou = ""
    begin
      ou += " ("
      ou += model.specific_organization.section.name
      org_name = model.specific_organization.organization.name
      if ((org_name != "(region)") && (org_name != "(section)"))
        ou += " " + org_name
      end
      if (!model.start_time.blank?)
        ou += ", " + model.start_time.strftime("%d %b %Y")
      end
      ou += ")"
    rescue
      ou = ""
    end
    subject += ou

    @subject              = subject
    @body["model"]        = model
    @recipients           = alert.email_address
    @from                 = YAML.load_file(File.join('config', 'email.yml'))["alert_from_address"]
    @sent_on              = Time.now
    @content_type         =  "text/html"
  end

  # Sent when a meeting is cancelled or un-cancelled
  def meeting_cancelled(meeting, meeting_registration, alert)
    # The operation (cancelling or un-cancelling) should already have been done
    @subject    = 'IEEE vTools Meeting ' + ((meeting.cancelled) ? "CANCELLED" : "REINSTATED")
    @body["meeting"] = meeting
    @body["meeting_registration"] = meeting_registration
    @recipients = alert.email_address
    @from       = YAML.load_file(File.join('config', 'email.yml'))["alert_from_address"] #'IEEE vTools.Meetings <no_reply@ieee.org>'
    @sent_on    = Time.now
  end

end
