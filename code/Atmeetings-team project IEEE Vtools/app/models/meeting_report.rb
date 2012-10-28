require 'tzinfo' #uncomment this line once you have installled the tzinfo gem file
require 'uri'

class MeetingReport < ActiveRecord::Base
  belongs_to :state
  belongs_to :country
  belongs_to :category
  belongs_to :specific_organization
  belongs_to :ldap_user,
             :foreign_key => "created_by"
  belongs_to :ldap_user,
             :foreign_key => "updated_by"
                        
  has_many :organizations, :through => :specific_organization
  has_many :speaker_reports, :dependent => :destroy
  
  validates_presence_of :title, :description, 
                        :keywords, :category_id,
                        :specific_organization,
                        :start_time, :end_time, :city, :tm_zone_info,
                        :guests_attending, :ieee_attending,
                        :country_id,
                        :state_id                            
  validates_format_of   :contact_email,                        
                        :with       => %r{\A([_a-zA-Z0-9\-!+]+(\.[_a-zA-Z0-9\-!+]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name)))?\z}i,
                        :message    => " must be valid."                            
                                        
  validates_associated  :speaker_reports,
                        :message => "contain an error - see speaker fields below"
                        
  validates_length_of   :title, :maximum => 256, :message=>" cannot be longer than 256 characters"
  validates_length_of   :description, :maximum => 8192, :message=>" cannot be longer than 8192 characters"
  validates_length_of   :city, :maximum => 128, :allow_nil => true, :message=>" cannot be longer than 128 characters."
  validates_length_of   :cosponsor_name, :maximum=>256, :allow_nil => true, :message=>" name cannot be larger than 256 characters."
  validates_length_of   :keywords, :maximum=>512, :message=>" cannot be larger than 512 characters."

  validates_length_of   :contact_email, :maximum=>512, :allow_nil => true, :message=>" cannot be larger than 512 characters."  

  validates_numericality_of :guests_attending, :greater_than_or_equal_to=>0
  validates_numericality_of :ieee_attending, :greater_than_or_equal_to=>0
  validate :validate_extension

  @@meeting_report_datetime_display_format = "%d %b %Y %H:%M"
  def self.datetime_display_format
    @@meeting_report_datetime_display_format
  end

  #@@meeting_report_search_datetime_format = "%d %b %Y %H:%M"
  def self.search_datetime_format
    @@meeting_report_datetime_display_format
  end

  @@per_page = 10
  def self.default_per_page
    @@per_page
  end

  # options include:
  #  :paginate=true/false (defaults to true)
  def self.search(params, options={}) #(search, page)

    if (options[:paginate].nil?)
      options[:paginate] = true
    end

    # If we're not paginating, then just use page 1 and a very large number per page
    if (options[:paginate])
      page = params[:page] || 1
      per_page = params[:per_page] || MeetingReport.default_per_page
    else
      page = 1
      per_page = 1000000
    end
    order = params[:order] || "region.name,section.name,start_time"

    select = "meeting_report.*"
    select += ", (ieee_attending + guests_attending) AS number_of_attendees"
    select += ", organization.name AS organization_name"
    select += ", specific_organization.name AS specific_organization_name"
    select += ", section.name AS section_name"
    select += ", region.name AS region_name"
    select += ", section.geocode AS section_geocode"
    select += ", categories.name AS categories_name"

    joins = "meeting_report inner join"
    joins += "("
    joins += "  ("
    joins += "    ("
    joins += "      specific_organizations as specific_organization"
    joins += "        inner join organizations as organization on specific_organization.organization_id = organization.id"
    joins += "    )"
    joins += "    inner join sections as section on specific_organization.section_id = section.id"
    joins += "  )"
    joins += "  inner join regions as region on section.region_id = region.id"
    joins += ")"
    joins += " on meeting_report.specific_organization_id = specific_organization.id"
    joins += " inner join categories on meeting_report.category_id = categories.id"

    conditions = []

    if (!params[:search].blank?)
      search = params[:search]
      if (!params[:use_exact])
        search = '%' + search + '%'
      end
      conditions.add_condition!(['meeting_report.title LIKE ? OR meeting_report.description LIKE ? OR meeting_report.keywords LIKE ?', search, search, search])
    end
    conditions.add_condition!(['categories.id = ?', params[:category_id]]) unless params[:category_id].blank?
    conditions.add_condition!(['organization.name LIKE ?', '%'+params[:society]+'%']) unless params[:society].blank?
    conditions.add_condition!(['region.id = ?', params[:meeting_report][:region_id]]) unless ((params[:meeting_report].blank?) || (params[:meeting_report][:region_id].blank?))
    conditions.add_condition!(['section.id = ?', params[:meeting_report][:section_id]]) unless ((params[:meeting_report].blank?) || (params[:meeting_report][:section_id].blank?))
    conditions.add_condition!(['organization.id = ?', params[:meeting_report][:organization_id]]) unless ((params[:meeting_report].blank?) || (params[:meeting_report][:organization_id].blank?))
    conditions.add_condition!(['start_time >= ?', DateTime.parse(params[:meeting_after]).strftime("%Y-%m-%d %H:%M")]) unless (params[:meeting_after].blank? || !params[:meeting_after].match(/^\d{2} \w{3} \d{4} \d{1,2}:\d{2}$/))
    conditions.add_condition!(['start_time <= ?', DateTime.parse(params[:meeting_before]).strftime("%Y-%m-%d %H:%M")]) unless (params[:meeting_before].blank? || !params[:meeting_before].match(/^\d{2} \w{3} \d{4} \d{1,2}:\d{2}$/))
    conditions.add_condition!(['created_on >= ?', DateTime.parse(params[:submitted_after]).strftime("%Y-%m-%d %H:%M")]) unless (params[:submitted_after].blank? || !params[:submitted_after].match(/^\d{2} \w{3} \d{4} \d{1,2}:\d{2}$/))
    conditions.add_condition!(['created_on <= ?', DateTime.parse(params[:submitted_before]).strftime("%Y-%m-%d %H:%M")]) unless (params[:submitted_before].blank? || !params[:submitted_before].match(/^\d{2} \w{3} \d{4} \d{1,2}:\d{2}$/))

    @meeting_reports = MeetingReport.paginate(
      :page=>page, :per_page=>per_page, :order=>order,
      :conditions=>conditions,
      :select=>select,
      :joins=>joins
    )
  end

  # Defines the columns that are included in search results, for web display and for CSV download
  def self.search_results_columns
    columns = []
    # Add our columns that are included in the search results and sort here, meeting_report columns should not
    #  need/have 'meeting_report.' prefix

    columns.push(Hash["Key","title",                "Label","Title",      "Title","Meeting Title",        "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","region.name",          "Label","Reg",        "Title","Region",               "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","section.name",         "Label","Sec",        "Title","Section",              "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","organization.name",    "Label","Org",        "Title","Organizational Unit",  "ShowOnWeb",true,   "ShowOnCSV",true])
    # Note that the following is problematic (related to sorting) right now because it's Key contains another Key in it ('organization.name')
    #columns.push(Hash["Key","specific_organization.name",         "Label","OU Type",        "Title","OU Type",              "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","start_time",           "Label","Date",       "Title","Meeting Date",         "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","created_on",           "Label","Rep. Date",  "Title","Reported on Date",     "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","submitter",            "Label","By",         "Title","Reported By",          "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","number_of_attendees",  "Label","Att",        "Title","Number of Attendees",  "ShowOnWeb",false,  "ShowOnCSV",true])
    columns.push(Hash["Key","ieee_attending",  "Label","IEEE Members Att",        "Title","Number of IEEE Member Attendees",  "ShowOnWeb",false,  "ShowOnCSV",true])
    columns.push(Hash["Key","guests_attending",  "Label","Non-Members Att",        "Title","Number of Non-Member Attendees",  "ShowOnWeb",false,  "ShowOnCSV",true])
    columns.push(Hash["Key","categories.name",      "Label","Type",       "Title","Meeting Type",         "ShowOnWeb",true,   "ShowOnCSV",true])

    return columns
  end


  def before_create
    if( self.tm_zone_info )
      convert_meeting_to_utc
    end
  end

  def before_update
    convert_meeting_to_utc
  end

  def after_find
    convert_meeting_to_local
  end

  def validate_extension
    errors.add(:guests_attending, " must be between 0 and 5000") if self.guests_attending and self.guests_attending < 0 and self.guests_attending > 5000
    errors.add(:ieee_attending, " must be between 0 and 5000") if self.ieee_attending and self.ieee_attending < 0 and self.ieee_attending > 5000

    errors.add(:ieee_attending, " NOTE: the number of IEEE members and guests must be greater than 0") if self.guests_attending == 0 and self.ieee_attending == 0
    errors.add(:guests_attending, " NOTE: the number of IEEE members and guests must be greater than 0") if self.guests_attending == 0 and self.ieee_attending == 0

    #errors.add(:specific_organization, "Region, Section, and Organizational Unit must be specified") if (!self.specific_organization)

    if (self.specific_organization_id)
      # We should have a specific_organization_id, and if we do, then it should be for a
      # specific organization was active within 3 years in the past.  This is the oldest
      # that ANY user should be able to create a report for (even admins).  There will be
      # another restriction for non-admin users to not be able to create a report for
      # specific orgs older than 1 year, but that must be handled in the controller
      # (see meeting_report_controller).
      if (self.new_record?)
        unless ((self.specific_organization.is_active?) || (self.specific_organization.was_active_during?(3.years)))
          errors.add(:specific_organization, "must have been active within three years")
        end
      end
    end

    if (self.start_time && self.end_time)
      # As long as we have a value for both of these, then go further with the validation
      #  If we don't have a value for either of these that error should already have been
      #  caught and included by validation
      errors.add(:start_time, " cannot be in the future") unless (self.start_time < Time.now)
      errors.add(:end_time, " cannot be in the future") unless (self.end_time < Time.now)
      errors.add(:end_time, " must be later than start time") if self.end_time <= self.start_time
      d1 = Date::civil(self.end_time.year, self.end_time.month, self.end_time.day)
      d2 = Date::civil(self.start_time.year, self.start_time.month, self.start_time.day)
      errors.add(:end_time, ":  meetings longer than 5 days are not allowed") if d1 - d2 > 5
    end
  end

  # creating a new meeting report with pre-filled attributes
  def self.create_new(m)
    mr=MeetingReport.new
    #difining a list of field to be filled in the report
    list = [:description,:keywords,:category_id,:specific_organization_id,:start_time,:end_time,:city,:country_id,:state_id,:tm_zone_info]
    list.each do |a|
      #filling the known attributes
      mr[a] = m[a]
    end  
    
    # creating a new speakers reports with pre-filled attributes
    m.speakers.each do |s|
      sr=SpeakerReport.create_new(s)
      mr.speaker_reports << sr
    end
    mr
  end
  
private

  def convert_meeting_to_utc
    tz = TZInfo::Timezone.get(self.tm_zone_info)
    if( self.start_time )
        self.start_time = tz.local_to_utc(self.start_time)
    end
    if( self.end_time )
        self.end_time = tz.local_to_utc(self.end_time)
    end
  end

  def convert_meeting_to_local
    tz = TZInfo::Timezone.get(self.tm_zone_info)
    if( self.start_time )
        self.start_time = tz.utc_to_local(self.start_time)
    end
    if( self.end_time )
        self.end_time = tz.utc_to_local(self.end_time)
    end
  end
  
  ## Validate URL (optionally allowing mailto urls)
  ## tbd: same code in meeting_report.rb
  def validate_url( url, allow_mail_to = false, accept_empty_string = true )
    if url == '' && accept_empty_string
      true
    else
      begin
        uri = URI.parse(url)
        if (uri.class == URI::MailTo) && allow_mail_to == true
          true
        elsif (uri.class != URI::HTTP) && (uri.class != URI::HTTPS) && (uri.class != URI::FTP) 
          false
        else
          true
        end
      rescue URI::InvalidURIError
        false
      end
    end
  end
end
