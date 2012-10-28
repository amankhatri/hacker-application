require 'tzinfo' #uncomment this line once you have installled the tzinfo gem file
require 'uri'
require 'geocoder'

class Meeting < ActiveRecord::Base
  NO_FEE = 0
  ADMISSION_FEE = 1
  CHARGEBACK_FEE = 2
 # tbd: Does following really need to be here?
 DEFAULT_TIMEZONE = 'Eastern Time (US & Canada)'

  def before_create
    self.revision_number = 0
    self.uid = uuid
    self.uid = self.uid.upcase
    if( self.tm_zone_info )
      convert_meeting_to_utc
    end
  end

  def before_update
    if self.revision_number and self.revision_number >= 0
      self.revision_number = self.revision_number + 1
    else
      self.revision_number = 0
    end
    convert_meeting_to_utc
  end

  def after_find
    # hack for bug #3165 https://rails.lighthouseapp.com/projects/8994/tickets/3165-activerecordmissingattributeerror-after-update-to-rails-v-234
    #
    # skip converting to local if attribute tm_zone_info does not exist
    convert_meeting_to_local if attribute_present?(:tm_zone_info)
  end

  validates_presence_of :title, 
                        :description, 
                        :keywords, 
                        :category_id,
                        :start_time,
                        :end_time,
                        :city, 
                        :specific_organization,
                        :contact_email,
                        :country_id,
                        :state_id

  validates_presence_of :reg_start_time, :message=>": Registration Starts cannot be blank"
  validates_presence_of :tm_zone_info, :message=>": Time Zone cannot be blank"

  # image/too large is caught by validate method below                      
  validates_format_of   :mime_type,
                        :with       =>  %r{\A(image\/(gif|jpg|jpeg|png|pjpeg|x-png|too_large))?\z}i,
                        :message    =>  " picture must be of type gif, jpg, jpeg, png."    
    
  validates_format_of   :contact_email,                        
                        :with       => %r{\A([_a-zA-Z0-9\-!+]+(\.[_a-zA-Z0-9\-!+]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name)))?\z}i,
                        :message    => " must be valid."                            
  
  validates_associated  :speakers,
                        :message => "contain an error - see speaker fields below."
                        
  validates_length_of   :title, :maximum => 256, :message=>" has a maximum length of 256 characters."
  validates_length_of   :description, :maximum => 8192, :message=>" cannot be longer than 8192 characters."
  validates_length_of   :postal_code, :maximum => 16, :allow_nil => true, :message=>" cannot be longer than 16 characters."
  validates_length_of   :address1, :maximum=>128, :allow_nil => true, :message=>" cannot be larger than 128 characters."
  validates_length_of   :address2, :maximum=>128, :allow_nil => true, :message=>" cannot be larger than 128 characters."
  validates_length_of   :city, :maximum=>128, :message=>" cannot be larger than 128 characters."
  validates_length_of   :menu1, :maximum=>64, :allow_nil => true, :message=>" cannot be larger than 64 characters."
  validates_length_of   :menu2, :maximum=>64, :allow_nil => true, :message=>" cannot be larger than 64 characters."
  validates_length_of   :menu3, :maximum=>64, :allow_nil => true, :message=>" cannot be larger than 64 characters."
  validates_length_of   :building, :maximum=>128, :allow_nil => true, :message=>" cannot be larger than 128"
  validates_length_of   :room_number, :maximum=>48, :allow_nil => true, :message=>" cannot be larger than 48 characters."
  validates_length_of   :map_url, :maximum=>512, :allow_nil => true, :message=>" cannot be larger than 512 characters."
  validates_length_of   :registration_url, :maximum=>512, :allow_nil => true, :message=>" cannot be larger than 512 characters."
  validates_length_of   :survey_url, :maximum=>512, :allow_nil => true, :message=>" cannot be larger than 512 characters."
  validates_length_of   :header, :maximum=>512, :allow_nil => true, :message=>" cannot be larger than 512 characters."
  validates_length_of   :footer, :maximum=>512, :allow_nil => true, :message=>" cannot be larger than 512 characters."
  validates_length_of   :cosponsor_name, :maximum=>256, :allow_nil => true, :message=>" name cannot be larger than 256 characters."
  validates_length_of   :keywords, :maximum=>512, :message=>" cannot be larger than 512 characters."

  validates_length_of   :contact_email, :maximum=>512, :allow_nil => true, :message=>" cannot be larger than 512 characters."
  validates_length_of   :contact_display, :maximum=>512, :allow_nil => true, :message=>" cannot be larger than 512 characters."
  validates_length_of   :agenda, :maximum=>8192, :allow_nil => true, :message=>" cannot be larger than 8192 characters."

  validates_numericality_of :max_registrations, :allow_nil => true

  validates_numericality_of :user_override_latitude, :allow_nil => true
  validates_numericality_of :user_override_longitude, :allow_nil => true
  validate :validate_orgs

  def validates_presence_of_only_msg(*attr_names)
    configuration = { :message => ActiveRecord::Errors.default_error_messages[:blank], :on => :save }
    configuration.update(attr_names.extract_options!)

    # can't use validates_each here, because it cannot cope with nonexistent attributes,
    # while errors.add_on_empty can
    send(validation_method(configuration[:on])) do |record|
      unless (configuration[:if] && !evaluate_condition(configuration[:if], record)) || (configuration[:unless] && evaluate_condition(configuration[:unless], record))
        record.errors.add_on_blank(configuration[:message])
      end
    end
  end

  def validate_orgs

    if (self.specific_organization_id)
      # We should have a specific_organization_id, and if we do, then it should be for a
      # specific organization that is either:
      # - active (for a new meeting)
      # - is active now or was active within 1 year in the past (for existing meeting)
      if (self.new_record?)
        unless (self.specific_organization.is_active?)
          errors.add(:specific_organization, "must be currently active")
        end
      else # Should be an existing record
        unless ((self.specific_organization.is_active?) || (self.specific_organization.was_active_during?(1.year)))
          errors.add(:specific_organization, "must have been active within one year")
        end
      end
    end

    errors.add(:picture, "too large") if self.mime_type == "image/too_large"

    if (self.start_time && self.end_time)
      # As long as we have a value for both of these, then go further with the validation
      #  If we con't have a value for either of these that error should already have been
      #  caught and included by validation
      errors.add(:end_time, " must be later than start time")     if self.end_time <= self.start_time
      d1 = Date::civil(self.end_time.year, self.end_time.month, self.end_time.day)
      d2 = Date::civil(self.start_time.year, self.start_time.month, self.start_time.day)
      errors.add(:end_time, ":  meetings longer than 5 days are not allowed") if d1 - d2 > 5
    end
    if (self.start_time && self.reg_start_time)
      if (!self.reg_end_time)
        errors.add(:reg_end_time, ": Registration Deadline is required (set Deadline to same day to turn off)")
      end
      errors.add(:reg_start_time, ": Registration start time must be earlier than meeting start time")  if self.reg_start_time >= self.start_time && self.reg_start_time != self.reg_end_time
    end
    if (self.end_time && self.reg_end_time && (self.reg_start_time != self.reg_end_time) )
      errors.add(:reg_end_time, ": Registration end time must be earlier than the end of meeting") if self.reg_end_time >= self.end_time
    end
    if ( self.reg_start_time && self.reg_end_time && (self.reg_start_time != self.reg_end_time) )
      errors.add(:reg_start_time, ": Registration start time must be earlier than registration end time")  if self.reg_start_time > self.reg_end_time
      r1 = Date::civil(self.reg_end_time.year, self.reg_end_time.month, self.reg_end_time.day)
      r2 = Date::civil(self.reg_start_time.year, self.reg_start_time.month, self.reg_start_time.day)
      if ( r1 == r2 && self.max_registrations && self.max_registrations !=0 )
        errors.add(:max_registrations, ": Maximum registrations non-zero while (internal) registration is disabled (registration start day same as registration end day)")
      end
    end

    errors.add(:max_registrations, ": Maximum registrations must be positive") if self.max_registrations && self.max_registrations < 0
    
    errors.add(:max_registrations, ": Maximum registrations must be less than 1000") if self.max_registrations && self.max_registrations > 999
    errors.add(:survey_url, ": is not a valid url (missing http:// or similar prefix?)." ) if self.survey_url && ! validate_url(self.survey_url)
    # registration url to allow mailto: uri
    errors.add(:registration_url, ": is not a valid url (missing http:// or similar prefix?)." ) if self.registration_url && ! validate_url(self.registration_url, true)

    # If EITHER user_override_latitude OR user_override_longitude are present, then they BOTH must be
    errors.add(:user_override_latitude, ": If Override Longitude is entered, then Override Latitude must also be") if ((self.user_override_latitude.blank?) && (!self.user_override_longitude.blank?))
    errors.add(:user_override_longitude, ": If Override Latitude is entered, then Override Longitude must also be") if ((!self.user_override_latitude.blank?) && (self.user_override_longitude.blank?))

    errors.add(:map_url, ": is not a valid url (missing http:// or similar prefix?)." ) if self.map_url && ! validate_url(self.map_url)
  end

  belongs_to :state
  belongs_to :country
  belongs_to :category
  belongs_to :specific_organization
# belongs_to :meeting     ## in database but not used
  belongs_to :ldap_user,
             :foreign_key => "created_by"
  belongs_to :ldap_user,
             :foreign_key => "updated_by"
                        
  has_many :organizations, :through => :specific_organization
  has_many :speakers, :dependent => :destroy
  has_many :alerts
  has_many :meeting_registrations
  has_one :registration_fee, :dependent => :destroy, :autosave => true
  has_many :menus, :dependent => :destroy, :autosave => true
  
  def uuid()
     sql = "SELECT UUID()"   
     record = connection.select_one(sql)
     return record['UUID()']
  end

  # The following are configuration for Geocoder to do a lookup after validation
  # based on the 'address_for_geocoding_and_mapping' method and set the values for
  # latitude and longitude
  geocoded_by :address_for_geocoding_and_mapping
  after_validation :geocode, :if => :address1_changed? or :address2_changed? or :city_changed? or :state_id_changed? or :country_id_changed?

  # Creates an address string from whatever info we have that can be used for
  # geocode and mapping lookup
  def address_for_geocoding_and_mapping

    city_state = self.city
    if (self.state_id)
      city_state += ", " + self.state.name
    end
    # We can build a 'full address' string, it will be used in a few
    # places below
    full_address = city_state
    if (!self.address2.blank?)
      full_address = self.address2 + ", " + full_address
    end
    if (!self.address1.blank?)
      full_address = self.address1 + ", " + full_address
    end
    if (!self.country_id.blank?)
      full_address += ", " + self.country.name
    end

    return full_address

  end

  # Auto-generated lat/long are stored in latitude and longitude columns, where user
  # override values are now stored in user_override_latitude and user_override_longitude.
  # The following access methods are provided to get whatever is appropriate for mapping.
  def latitude_for_mapping
    if (!self.user_override_latitude.blank?)
      return self.user_override_latitude
    else
      return self.latitude
    end
  end
  def longitude_for_mapping
    if (!self.user_override_longitude.blank?)
      return self.user_override_longitude
    else
      return self.longitude
    end
  end

  # Convenience methods
  def no_fee?
    !self.charge?
  end

  def fee_is_admission?
    self.charge and self.cost?
  end

  def fee_is_chargeback?
    self.charge and !self.cost
  end

  def set_no_fee
    self.charge = false
    self.cost = false #not important, just to keep consistent
  end

  def set_admission_fee
    self.charge = true
    self.cost = true
  end

  def set_chargeback_fee
    self.charge = true
    self.cost = false
  end

  def has_region_merchant_acct?
    !self.region_merchant_acct.blank?
  end

  def has_section_merchant_acct?
    !self.section_merchant_acct.blank?
  end

  # Returns true if the OU represents a region - both section name and OU name
  # will be '(region)'. Also true if it represents a chapter or affinity group
  # that is a direct child of a region - section name will be '(region)' and
  # OU name will be a non-blank value.
  def is_region_unit_meeting?
    so = self.specific_organization
    return false if so.blank? or so.section.blank? or so.organization.blank?
    section_name = so.section.name
    org_name = so.organization.name

    return (section_name == '(region)' and !org_name.blank?)
  end

  # Returns true if the OU represents a section - section name will be a
  # non-blank value other than '(region)' and OU name will be '(section)'.
  # Also true if it represents a chapter or affinity group that is a
  # direct child of a section - section name will be a non-blank value
  # other than '(region)' and OU name will be some non-blank value.
  def is_section_unit_meeting?
    so = self.specific_organization
    return false if so.blank? or so.section.blank? or so.organization.blank?
    section_name = so.section.name
    org_name = so.organization.name

    return (!section_name.blank? and section_name != '(region)' and
      !org_name.blank?)
  end

  # Currently only allow online payments for regions and sections. Change
  # this when adding support for other types of organizations.
  def can_accept_online_payment?
    if self.is_region_unit_meeting? and self.has_region_merchant_acct? and
      !self.region_merchant_currency.blank?
      return true
    end

    if self.is_section_unit_meeting? and self.has_section_merchant_acct? and
      !self.section_merchant_currency.blank?
      return true
    end

    return false
  end

  # Whether registration is currently open. Takes into account if registration is
  # 'disabled', and registration start and end times (but NOT whether the meeting
  # is cancelled or if all spaces have been filled!)
  def registration_open
    open = false
    # If reg start time and end time are the same, then no registration
    if (self.reg_start_time != self.reg_end_time)
      # Do it all in UTC, if we have no time zone info then assume we're already in UTC
      r_start = self.reg_start_time
      r_end = self.reg_end_time
      if (!self.tm_zone_info.blank?)
        tz = TZInfo::Timezone.get(self.tm_zone_info)
        r_start = tz.local_to_utc(r_start)
        r_end = tz.local_to_utc(r_end)
      end
      now = Time.now.utc

      open = ((r_start < now) && (now < r_end))
    end
    return open
  end
  def registration_closed
    return !registration_open
  end


    #Formats a string into the correct URL Syntax for addition to Google Calendar
  def google_calendar
    tz = TZInfo::Timezone.get(self.tm_zone_info)
    self.start_time = tz.local_to_utc(self.start_time)
    self.end_time = tz.local_to_utc(self.end_time)
    calendar_url = "http://www.google.com/calendar/event?action=TEMPLATE"
    calendar_url << "&text=" << self.title
    calendar_url << "&dates=" << self.start_time.strftime("%Y%m%d") << "T" << self.start_time.strftime("%H%M%S") << "Z/" << self.end_time.strftime("%Y%m%d") << "T" << self.end_time.strftime("%H%M%S") << "Z"
    # If description is too long, the URL will get rejected by Google..
    desc = self.description
    if (desc.length > 1000)
      desc = desc[0..1000] + " ..."
    end
    calendar_url << "&details=" << desc
    calendar_url << "&location="
    calendar_url << self.address1 if self.address1?
    calendar_url << " " << self.address2 if self.address2?
    calendar_url << " " << self.city << "," if self.city?
    calendar_url << " " << self.state.name if self.state
    calendar_url << " " << self.country.name if self.country
    calendar_url << " " << self.postal_code if self.postal_code?
    calendar_url << "&trp=true"
    URI.escape(calendar_url)
   end

  # Search properties and methods

  @@meeting_datetime_display_format = "%d %b %Y %H:%M"
  def self.datetime_display_format
    @@meeting_datetime_display_format
  end

  #@@meeting_report_search_datetime_format = "%d %b %Y %H:%M"
  def self.search_datetime_format
    @@meeting_datetime_display_format
  end

  @@per_page = 10
  def self.default_per_page
    @@per_page
  end

  # options include:
  #  :paginate=true/false (defaults to true)
  #  :show_unpublished (:none (only show published meetings), :include (show both
  #  published and unpublished meetings), and :only (show only unplublished meetings)
  #  , defaults to :none
  def self.search(params, options={}) #(search, page)

    if (!options[:show_unpublished])
      options[:show_unpublished] = :none
    end

    if (options[:paginate].nil?)
      options[:paginate] = true
    end

    # If we're not paginating, then just use page 1 and a very large number per page
    if (options[:paginate])
      page = params[:page] || 1
      per_page = params[:per_page] || Meeting.default_per_page
    else
      page = 1
      per_page = 1000000
    end
    order = params[:order] || "start_time,region.name,section.name"

    select = "meeting.*"
    #select += ", (ieee_attending + guests_attending) AS number_of_attendees"
    select += ", organization.name AS organization_name"
    select += ", specific_organization.name AS specific_organization_name"
    select += ", section.name AS section_name"
    select += ", region.name AS region_name"
    select += ", section.geocode AS section_geocode"
    select += ", categories.name AS categories_name"
    # To include info about how many people have registered:
    #select += ", COUNT(meeting_registrations.meeting_id) AS registration_count"

    joins = "meeting inner join"
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
    joins += " on meeting.specific_organization_id = specific_organization.id"
    joins += " inner join categories on meeting.category_id = categories.id"
    # To include info about how many people have registered:
    #joins += " left outer join meeting_registrations on meeting_registrations.meeting_id = meeting.id"

    conditions = []

    if (!params[:search].blank?)
      search = params[:search]
      if (!params[:use_exact])
        search = '%' + search + '%'
      end
      conditions.add_condition!(['meeting.title LIKE ? OR meeting.description LIKE ? OR meeting.keywords LIKE ?', search, search, search])
    end
    conditions.add_condition!(['categories.id = ?', params[:category_id]]) unless params[:category_id].blank?
    conditions.add_condition!(['organization.name LIKE ?', '%'+params[:society]+'%']) unless params[:society].blank?
    conditions.add_condition!(['region.id = ?', params[:meeting][:region_id]]) unless ((params[:meeting].blank?) || (params[:meeting][:region_id].blank?))
    conditions.add_condition!(['section.id = ?', params[:meeting][:section_id]]) unless ((params[:meeting].blank?) || (params[:meeting][:section_id].blank?))
    conditions.add_condition!(['organization.id = ?', params[:meeting][:organization_id]]) unless ((params[:meeting].blank?) || (params[:meeting][:organization_id].blank?))
    conditions.add_condition!(['start_time >= ?', DateTime.parse(params[:meeting_after]).strftime("%Y-%m-%d %H:%M")]) unless (params[:meeting_after].blank? || !params[:meeting_after].match(/^\d{2} \w{3} \d{4} \d{1,2}:\d{2}$/))
    conditions.add_condition!(['start_time <= ?', DateTime.parse(params[:meeting_before]).strftime("%Y-%m-%d %H:%M")]) unless (params[:meeting_before].blank? || !params[:meeting_before].match(/^\d{2} \w{3} \d{4} \d{1,2}:\d{2}$/))
    conditions.add_condition!(['created_on >= ?', DateTime.parse(params[:submitted_after]).strftime("%Y-%m-%d %H:%M")]) unless (params[:submitted_after].blank? || !params[:submitted_after].match(/^\d{2} \w{3} \d{4} \d{1,2}:\d{2}$/))
    conditions.add_condition!(['created_on <= ?', DateTime.parse(params[:submitted_before]).strftime("%Y-%m-%d %H:%M")]) unless (params[:submitted_before].blank? || !params[:submitted_before].match(/^\d{2} \w{3} \d{4} \d{1,2}:\d{2}$/))
    conditions.add_condition!(['virtual=?',true]) unless params[:virtual].blank?
    
    if ((params['geo_distance']) && (!params['geo_distance'].blank?) &&
        (params['geo_search']) && (!params['geo_search'].blank?))

      # First we get the lat and lon to search around, using the Geocoder utility
      # method should handle actual lat,lon entered, or addresses, etc.
      lat,lon = Geocoder::Calculations.extract_coordinates(params['geo_search'])

      # Then we use the Geocoder's method for producing the select and where clauses
      # We can use these along with any other search criteria submitted.
      # (need to use Meeting.send because the full_near_scope_options is protected)
      #full_near_scope_options(latitude, longitude, radius, options)
      near_scope_options = Meeting.send(:full_near_scope_options, lat, lon, params['geo_distance'], {})

      # near_scope_options[:order] will look something like this:
      #
      # 3958.755864232 * 2 * ASIN(SQRT(POWER(SIN((40.5418813 - latitude) * PI()
      # / 180 / 2), 2) + COS(40.5418813 * PI() / 180) * COS(latitude * PI() / 180)
      # * POWER(SIN((-74.4724889 - longitude) * PI() / 180 / 2), 2) )) ASC
      #
      # This is is a calculation for distance, which we should be able to use to
      # include distance in the select clause with a minor tweak
      distance_calc = near_scope_options[:order].gsub(" ASC", "")

      # We now have to take user_override_latitude/longitude into account here as well
      distance_select = "IF("
      distance_select += " ( (user_override_latitude IS NULL) AND (user_override_longitude IS NULL) )"
      # If there are no overrides, then we want the one that was generated as-is (using latitude/longitude)
      distance_select += ", ( " + distance_calc + " )"
      # Otherwise, there are overrides, so use those
      distance_select += ", ( " + distance_calc.gsub("latitude", "user_override_latitude").gsub("longitude", "user_override_longitude") + " ) "
      distance_select += ")"

      select += ", " + distance_select + " AS distance"

      # THE FOLLOWING WILL BE USEFUL FOR WHEN WE UPGRADE geocoder TO VERSION 1.1.0+!!!
=begin
      # near_scope_options[:select] will look something like this:
      #
      # <meetings prefix>, 3958.755864232 * 2 * ASIN(SQRT(POWER(SIN((42.0710458 - latitude) * PI() / 180 / 2), 2) + COS(42.0710458 * PI() / 180) * COS(latitude * PI() / 180) * POWER(SIN((-72.6742455 - longitude) * PI() / 180 / 2), 2) )) AS distance, CAST(DEGREES(ATAN2( RADIANS(longitude - -72.6742455), RADIANS(latitude - 42.0710458))) + 360 AS decimal) % 360 AS bearing
      #
      # where <meetings prefix> is either "*" (for geocoder version 1.0.5) or
      # "meetings.*" (for geocoder version 1.1.0).
      #
      # This is is a calculation for distance (and bearing), which we should be able to use to
      # include distance in our select clause with a minor tweak
      meetings_prefix_ndx = near_scope_options[:select].index("*,")
      if (!meetings_prefix_ndx)
        throw "It appears that the geocoder API has changed, expecting a meetings prefix on near_scope_options[:select]!!"
      end
      # Use the select retrieved, minus the meetings prefix
      select += ", " + near_scope_options[:select].slice((meetings_prefix_ndx+2), (near_scope_options[:select].length-(meetings_prefix_ndx+2)))
=end
      
      # near_scope_options[:conditions] should be an array with the first element
      # the condition clause and the rest the parameters, perfect for adding into
      # our other conditions

      # Now that we can have UserOverrideLatitude/Longitude, we'll need to get a bit
      # more fancy with this condition.  If there are values for these overrides,
      # then those should be what's considered, otherwise the standard/automatic
      # Latitude/Longitude should be what's looked at.

      # For geocoder 1.0.5, what we'll have here is a 0 element that looks something
      # like 'latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?', with 4 more
      # elements that are the values for those ?.  What we're going to do is to
      # extend the 0 element to make it cover both the override lat/long and the
      # standard/automatic lat/long, and then we'll have to add

      # ALL THIS WILL HAVE TO CHANGE WITH geocoder VERSION 1.1.0!! :-(

      orig_condition = near_scope_options[:conditions][0]
      new_condition = ""
      new_condition += "("
      new_condition += " ("
      new_condition +=  " (user_override_latitude IS NOT NULL)"
      new_condition +=  " AND"
      new_condition +=  " (user_override_longitude IS NOT NULL)"
      new_condition +=  " AND"
      new_condition +=  " ("
      new_condition +=  orig_condition.gsub("latitude", "user_override_latitude").gsub("longitude", "user_override_longitude")
      new_condition +=   ")"
      new_condition += " )"
      new_condition += " OR"
      new_condition += " ("
      new_condition +=  " (user_override_latitude IS NULL)"
      new_condition +=  " AND"
      new_condition +=  " (user_override_longitude IS NULL)"
      new_condition +=  " AND"
      new_condition +=  " (latitude IS NOT NULL)"
      new_condition +=  " AND"
      new_condition +=  " (longitude IS NOT NULL)"
      new_condition +=  " AND"
      new_condition +=  " ("
      new_condition +=  orig_condition
      new_condition +=   ")"
      new_condition += " ) "
      new_condition += ")"

      near_scope_options[:conditions][0] = new_condition

      # So now i believe we need to repeat the 4 parameters, since we've created
      # 4 additional ? in the condition SQL
      near_scope_options[:conditions].push(near_scope_options[:conditions][1])
      near_scope_options[:conditions].push(near_scope_options[:conditions][2])
      near_scope_options[:conditions].push(near_scope_options[:conditions][3])
      near_scope_options[:conditions].push(near_scope_options[:conditions][4])

      conditions.add_condition!(near_scope_options[:conditions])

    else

      # If we're not searching by geo, we still want to add in a column in the
      # query called 'distance' so that if distance was involved in the sort order
      # we won't get any errors when the query uses it in the ORDER BY clause
      select += ", NULL AS distance"

    end

    # Choose what type of published states to include
    case options[:show_unpublished]
    when :only
      conditions.add_condition!(['meeting.publish = ?', false])
    when :none
      conditions.add_condition!(['meeting.publish = ?', true])
    else

    end
    
    @meetings = Meeting.paginate(
      :page=>page, :per_page=>per_page, :order=>order,
      :conditions=>conditions,
      :select=>select,
      :joins=>joins
      # To include info about how many people have registered:
      #:group=>"meeting.id"
    )

  end

  # Defines the columns that are included in search results, for web display and for CSV download
  def self.search_results_columns
    columns = []
    # Add our columns that are included in the search results and sort here, meeting columns should not
    #  need/have 'meeting.' prefix

    # Clickable title
    columns.push(Hash[
        "Key", "title",
        "Label", "Title",
        "Title", "Meeting Title",
        "ShowOnWeb", true,
        "ShowOnCSV", true,
        "lambda", lambda { |meeting, options|
          output = meeting.title
          unless (options[:is_csv])
            # So this is NOT a CSV, right? Still haven't internalized that 'unless'.. :-D
            if (output.length > 40)
              output = '<span title="' + CGI::escapeHTML(output) + '">' + ERB::Util::html_escape(output[0..36]) + '...</span>'
            else
              output = ERB::Util::html_escape(output)
            end
            output = "<a href='/meeting_view/list_meeting/#{meeting.id}'>#{output}</a>"
          end
          return output
        }
    ])

    columns.push(Hash["Key","start_time",           "Label","Date",       "Title","Meeting Date",         "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","categories.name",      "Label","Type",       "Title","Meeting Type",         "ShowOnWeb",false,  "ShowOnCSV",true])

    columns.push(Hash["Key","region.name",          "Label","Reg",        "Title","Region",               "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","section.name",         "Label","Sec",        "Title","Section",              "ShowOnWeb",true,   "ShowOnCSV",true])
    columns.push(Hash["Key","organization.name",    "Label","Org",        "Title","Organizational Unit",  "ShowOnWeb",false,  "ShowOnCSV",true])
    # Note that the following is problematic (related to sorting) right now because it's Key contains another Key in it ('organization.name')
    #columns.push(Hash["Key","specific_organization.name",         "Label","OU Type",        "Title","OU Type",              "ShowOnWeb",true,   "ShowOnCSV",true])

    # Not sure if we need address1 and address2 if we have the full location below
    #columns.push(Hash["Key","address1",             "Label","Address1",   "Title","Address1",             "ShowOnWeb",false,  "ShowOnCSV",true])
    #columns.push(Hash["Key","address2",             "Label","Address2",   "Title","Address2",             "ShowOnWeb",false,  "ShowOnCSV",true])
    columns.push(Hash[
        "Key", "city",
        "Label", "Location",
        "Title", "Meeting Location",
        "ShowOnWeb", true,
        "ShowOnCSV", true,
        "lambda", lambda { |meeting, options|

          full_address = meeting.address_for_geocoding_and_mapping

          link_display = meeting.city
          if (meeting.state_id)
            link_display += ", " + meeting.state.name
          end
          if (link_display.length > 20)
            link_display = '<span title="' + CGI::escapeHTML(link_display) + '">' + ERB::Util::html_escape(link_display[0..16]) + '...</span>'
          end

          if (options[:is_csv])
            # If we're outputting for CSV, then just use full address
            output = full_address
          else
            # If we're outputting html, then we want build a Google Maps link
            output = "<a href='http://maps.google.com/maps?q=#{full_address}'>#{link_display}</a>"
          end

          return output
        }
    ])

    columns.push(Hash[
        "Key", "virtual",
        "Label", "Virtual?",
        "Title", "Virtual?",
        "ShowOnWeb", true,
        "ShowOnCSV", true,
        "lambda", lambda { |meeting, options| (meeting.virtual? ? "Yes" : "No") }
    ])
  
    columns.push(Hash[
        "Key", "url",
        "Label", "URL",
        "Title", "Meeting URL",
        "ShowOnWeb", false,
        "ShowOnCSV", true,
        "lambda", lambda { |meeting, options|
          # NOTE that in order to have request.env here we have to jump through
          # some hoops in meeting_view_controller, search_output, search_output_helper.. :-/
          return "http://#{options[:request].env["SERVER_NAME"]}/meeting_view/list_meeting/#{meeting.id.to_s}"
        }
    ])

    columns.push(Hash[
        "Key", "distance",
        "Label", "Distance",
        "Title", "Distance from specified location",
        "ShowOnWeb", lambda { |meetings|
          # We'll show the distance column if there is a distance field in at
          # least one meeting that is non-null
          show = false
          meetings.each { |me|
            if ((me.respond_to?:distance) && (!me.distance.blank?))
              show = true
            end
          }
          return show
        },
        "ShowOnCSV", false,
        "lambda", lambda { |meeting, options|
          if ((meeting.respond_to?:distance) && (!meeting.distance.blank?))
            return meeting.distance.to_f.round(2).to_s + " miles"
          else
            return "n/a"
          end
        }
    ])

    # To include info about how many people have registered (more needs to be
    # uncommented in Meeting model):
    #columns.push(Hash["Key","registration_count",   "Label","Reg",        "Title","Registered Attendees", "ShowOnWeb",true,  "ShowOnCSV",true])
    #columns.push(Hash["Key","max_registrations",    "Label","Max",        "Title","Maximum Attendees",    "ShowOnWeb",true,  "ShowOnCSV",true])

    return columns
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
    if( self.reg_start_time )
        self.reg_start_time = tz.local_to_utc(self.reg_start_time)
    end
    if( self.reg_end_time )
        self.reg_end_time = tz.local_to_utc(self.reg_end_time)
    end
  end

  def convert_meeting_to_local
    # BUG: tzinfo only adjusts offsets, the object's timezone will be UTC
    #      this is a restriction of the package
    #      Use     
    tz = TZInfo::Timezone.get(self.tm_zone_info)
    if( self.start_time )
        self.start_time = tz.utc_to_local(self.start_time)
    end
    if( self.end_time )
        self.end_time = tz.utc_to_local(self.end_time)
    end
    if( self.reg_start_time )
        self.reg_start_time = tz.utc_to_local(self.reg_start_time)
    end
    if( self.reg_end_time )
        self.reg_end_time = tz.utc_to_local(self.reg_end_time)
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
