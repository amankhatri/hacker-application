require File.dirname(__FILE__) + '/../test_helper'

# Used in test_meeting_search_columns
class FakeRequest
  attr_accessor :env
end

# A class to test the meeting model
class MeetingTest < ActiveSupport::TestCase
  # fixtures :meetings, :categories, :specific_organizations

  # Tests to see if the model returns local time
  def test_returns_local
    
    # how? assert_equal :utc, config.active_record.default_timezone
    m1 = Meeting.find(:all, :conditions => ["id=?", 1])
    
    m = m1[0]
    
    assert_equal "CST6CDT", m.tm_zone_info
    tz = TZInfo::Timezone.get(m.tm_zone_info)
    start_time = tz.utc_to_local(Time.now.beginning_of_day.utc + 39.hours)
    end_time = tz.utc_to_local(Time.now.beginning_of_day.utc + 40.hours)
    assert_equal start_time.strftime("%Y-%m-%d %H:%M:%S"), m.start_time.strftime("%Y-%m-%d %H:%M:%S")
    assert_equal end_time.strftime("%Y-%m-%d %H:%M:%S"), m.end_time.strftime("%Y-%m-%d %H:%M:%S")
  end

  def test_meeting_publish_on
    m1 = Meeting.find(:all, :conditions => ["id=?", 3])
    m = m1[0]
    m.publish = true
    m.specific_organization = SpecificOrganization.find(101)
    assert m.save, "saved publish on"
  end
  
  def test_meeting_publish_off
    m1 = Meeting.find(:all, :conditions => ["id=?", 3])
    m = m1[0]
    m.publish = false
    m.specific_organization = SpecificOrganization.find(101) 
    assert m.save, "saved publish off"
  end
  
  
  def test_meeting_create
        
  end
  
  def test_meeting_delete
    
  end
  
  # Tests length of postal_code <= 16
  def test_good_length_of_postal_code
    m1 = Meeting.find(:all, :conditions => ["id=?", 3])
    m = m1[0]
    
    m.specific_organization = SpecificOrganization.find(101)
    m.postal_code = "0123456789ABCDEF"
    assert m.save, "postal_code was updated"    
  end
  
  def test_map_url_can_end_with_slash
    m = Meeting.find(:first, :conditions => ["id=?", 3])
    m.map_url = "http://www.ieee.org/"
    assert m.save, "URL ending with slash (/) not allowed"    
  end

  def test_registration_url_with_mailto
    m = Meeting.find(:first, :conditions => ["id=?", 3])
    m.registration_url = "mailto:noone@ieee.org?Subject=Hello%20World&CC=secret@ieee.org"
    assert m.save, "mailto not allowed in registration url"    
  end
   
  # Tests length of meeting postal_code > 16
  def test_bad_length_of_postal_code
    m1 = Meeting.find(:all, :conditions => ["id=?", 3])
    m = m1[0]

    m.specific_organization = SpecificOrganization.find(101)  
    m.postal_code = "0123456789ABCDEFG"
    assert !m.save, "long postal_code was not saved"    
  end

  # Tests length of meeting description <= 2048
  def test_good_length_of_description
    m1 = Meeting.find(:all, :conditions => ["id=?", 3])
    m = m1[0]
    str = "0123456789ABCDEF"
    
    while str.length <= 8144
      str << "0123456789ABCDEF"
    end  
    m.specific_organization = SpecificOrganization.find(101)
    m.description = str
    m.postal_code = "0123456789ABCDEF"
    assert m.save, "description was updated"    
  end
   
  # Tests length of meeting description > 2048
  def test_bad_length_of_description
    m1 = Meeting.find(:all, :conditions => ["id=?", 3])
    m = m1[0]
    str = "0123456789ABCDEF"
        
    while str.length <= 8192
      str << "0123456789ABCDEF"
    end
    m.specific_organization = SpecificOrganization.find(101)  
    m.postal_code = "0123456789ABCDEF"
    m.description = str
    assert !m.save, "long description was not saved"    
  end
    
  # Tests to see if a string with length < 256 can be saved to the Title field
  def test_good_length_of_title
    m1 = Meeting.find(:all, :conditions => ["id=?", 3])
    m = m1[0]
    str = "0123456789ABCDEF"
    
    while str.length <= 240
      str << "0123456789ABCDEF"
    end  
    m.specific_organization = SpecificOrganization.find(101)
    m.postal_code = "0123456789ABCDEF"
    m.title = str
    assert m.save, "title was updated"    
  end

  # Tests to see if a string with length > 256 cannot be saved to the Title field
  def test_bad_length_of_title
    m1 = Meeting.find(:all, :conditions => ["id=?", 3])
    m = m1[0]
    str = "0123456789ABCDEF"
        
    while str.length <= 257
      str << "0123456789ABCDEF"
    end
    m.specific_organization = SpecificOrganization.find(101)  
    m.postal_code = "0123456789ABCDEF"
    m.title = str
    assert !m.save, "long title was not saved"    
  end
  
  # Tests the published, created and updated fields
  def test_other_times_from_fixture
    m1 = Meeting.find(:all, :conditions => ["id=?", 1])
    m = m1[0];
    
    assert_not_nil m.created_on
    assert_not_nil m.updated_on
  end
 
  # Tests to see if a well formatted email address is saved to database for contact email
  def test_good_email_field_from_fixture
    m = Meeting.find(:first)
    m.specific_organization = SpecificOrganization.find(101)
    m.postal_code = "0123456789"
    m.contact_email = "fortpayne@al.com"
    assert m.save, "Good email edit"
  end
  
  # Test to see if a improper formatted email address cannot be saved to database for contact email
  def test_bad_email_field_from_fixture
    m = Meeting.find(:first)
    m.specific_organization = SpecificOrganization.find(101)
    m.contact_email = "selma.al.com"
    m.postal_code = "0123456789"
    assert !m.save, "Email address is invalid"
  end

  # Test ability to create a new meeting record
  def test_tims_new_create
    m = Meeting.new
    m.title = "XYZZY"
    m.description = "XYZZY testing - a record made through Rails"
    m.start_time = "2006-07-31 17:00:30"
    m.end_time = "2006-07-31 19:00:00"
    m.reg_start_time = "2006-06-01 17:00:30"
    m.reg_end_time = "2006-06-01 17:00:30"
    m.tm_zone_info = "CST6CDT"
    m.keywords = "testing"
    m.city = "Birmingham"
    m.category_id = 1
    m.specific_organization = SpecificOrganization.find(101)
    m.mime_type = nil
    m.postal_code = "0123456789ABCDEF"
    m.country_id = 1
    m.state_id = 1
    # added (publish_off check added to meeting_test)
    m.contact_email = "fred@test.com"
    m.uid = 1
    m.save!
    m1 = Meeting.find_by_title("XYZZY")
    
    assert_equal "XYZZY", m1.title

    assert_equal "CST6CDT", m1.tm_zone_info
    assert_equal "2006-07-31 17:00:30", m1.start_time.strftime("%Y-%m-%d %H:%M:%S")
    assert_equal "2006-07-31 19:00:00", m1.end_time.strftime("%Y-%m-%d %H:%M:%S")

    # these two are supposed to be auto-maintained by Rails but Yaml 
    # load does NOT set them
    assert_not_nil m1.created_on
    assert_not_nil m1.updated_on

    gcal = "http://www.google.com/calendar/event?action=TEMPLATE&text=XYZZY&dates=20060731T220030Z/20060801T000000Z&details=XYZZY%20testing%20-%20a%20record%20made%20through%20Rails&location=%20Birmingham,%20Confusion%20Neverland%200123456789ABCDEF&trp=true"
    assert_equal gcal, m1.google_calendar()
  end

  def test_creating_and_editing_meeting_with_active_and_inactive_specific_organization
    
    so = SpecificOrganization.find(1870)

    m = Meeting.new
    m.title = "test_creating_and_editing_meeting_with_active_and_inactive_specific_organization"
    m.description = "test_creating_and_editing_meeting_with_active_and_inactive_specific_organization"
    m.start_time = Time.now + 15.days
    m.end_time = Time.now + 15.days + 3.hours
    m.reg_start_time = Time.now
    m.reg_end_time = Time.now + 15.days
    m.tm_zone_info = "CST6CDT"
    m.keywords = "testing"
    m.city = "Birmingham"
    m.category_id = 1
    m.specific_organization = so
    m.mime_type = nil
    m.postal_code = "0123456789ABCDEF"
    m.country_id = 1
    m.state_id = 1
    m.contact_email = "fred@test.com"
    m.uid = 1
    
    so.activated = Time.now + 10.days
    so.save!

    assert(!m.save, "Should not be able to save with specific organization not active")
    assert_equal("must be currently active", m.errors[:specific_organization][0])
    assert(m.new_record?)

    so.activated = Time.now - 10.days
    so.deactivated = Time.now - 5.days
    so.save!

    assert(!m.save, "Should not be able to save with specific organization not active")
    assert_equal("must be currently active", m.errors[:specific_organization][0])
    assert(m.new_record?)

    so.deactivated = nil
    so.save!

    assert(m.save, "Should be able to save with specific organization active")
    assert(!m.new_record?)

    so.activated = Time.now + 10.days
    so.save!

    m = Meeting.find_by_title("test_creating_and_editing_meeting_with_active_and_inactive_specific_organization")
    m.specific_organization = so
    m.title = "test_creating_and_editing_meeting_with_active_and_inactive_specific_organization EDITED"
    assert(!m.save, "Should not be able to save with specific organization not active")
    assert_equal("must have been active within one year", m.errors[:specific_organization][0])

    so.activated = Time.now - 2.years
    so.deactivated = Time.now - 1.year - 2.months
    so.save!

    m = Meeting.find_by_title("test_creating_and_editing_meeting_with_active_and_inactive_specific_organization")
    assert(!m.save, "Should not be able to save with specific organization not active")
    assert_equal("must have been active within one year", m.errors[:specific_organization][0])

    so.activated = Time.now - 2.years
    so.deactivated = Time.now - 11.months
    so.save!

    m = Meeting.find_by_title("test_creating_and_editing_meeting_with_active_and_inactive_specific_organization")
    assert(m.save, "Should be able to save with specific organization active within 1 year")
    
  end

  def test_meeting_search
    
  end

  def test_meeting_search_result_columns

    columns = Meeting.search_results_columns

    # columns should be a non-empty array
    assert_instance_of(Array, columns)
    assert columns.length > 0

    # Get a meeting to facilitate some tests of the columns
    meet = Meeting.find(13) # meeting fixture used as source for Geocoder.nearbys
    
    # Title should be different based on whether we're outputting to CSV or not
    assert_equal(columns[0]["Key"], "title")
    assert_equal(columns[0]["lambda"].call(meet, { :is_csv=>true }), meet.title)
    assert_equal(columns[0]["lambda"].call(meet, { :is_csv=>false }), "<a href='/meeting_view/list_meeting/#{meet.id}'>#{meet.title}</a>")

    # Location also should vary for CSV and web
    assert_equal(columns[6]["Key"], "city")
    assert_equal(columns[6]["lambda"].call(meet, { :is_csv=>true }), meet.address_for_geocoding_and_mapping)
    display = meet.city + ", " + meet.state.name
    if (display.length > 20)
      display = '<span title="' + display + '">' + display[0..16] + '...</span>'
    end
    generated_map_link = "<a href='http://maps.google.com/maps?q=#{meet.address_for_geocoding_and_mapping}'>#{display}</a>"
    assert_equal(columns[6]["lambda"].call(meet, { :is_csv=>false }), generated_map_link)

    # URL will be the same for CSV or web, but depends on request server
    assert_equal(columns[8]["Key"], "url")
    fake_env = Hash.new
    fake_env["SERVER_NAME"] = "fake.server"
    fake_req = FakeRequest.new
    fake_req.env = fake_env
    assert_equal(columns[8]["lambda"].call(meet, { :is_csv=>true, :request=>fake_req }), "http://#{fake_env['SERVER_NAME']}/meeting_view/list_meeting/#{meet.id.to_s}")
    assert_equal(columns[8]["lambda"].call(meet, { :is_csv=>false, :request=>fake_req }), "http://#{fake_env['SERVER_NAME']}/meeting_view/list_meeting/#{meet.id.to_s}")

    # Distance should only be displayed on the web, and only if there is a distance attribute (which is populated by Geocoder)
    assert_equal(columns[9]["Key"], "distance")
    # Without geo this should NOT be displayed
    all_meetings = Meeting.find(:all)
    assert(all_meetings.length > 0)
    assert(!columns[9]["ShowOnWeb"].call(all_meetings))
    all_meetings.each { |m|
      assert_equal(columns[9]["lambda"].call(m, {}), "n/a")
    }
    # With distance (geo_, this should be displayed
    meetings_with_distance = Meeting.find_by_sql("SELECT *, 1.2547 AS distance FROM meetings")
    assert(meetings_with_distance.length > 0)
    assert(columns[9]["ShowOnWeb"].call(meetings_with_distance))
    meetings_with_distance.each { |m|
      assert_equal(columns[9]["lambda"].call(m, {}), "#{m.distance.to_f.round(2).to_s} miles")
    }

  end

  # Test lat/long functionality
  def test_latitude_longitude

    m = Meeting.new
    m.title = "Lat/Lon Tester"
    m.description = "Lat/Lon testing - a record made through Rails"
    m.start_time = "2012-07-31 17:00:30"
    m.end_time = "2012-07-31 19:00:00"
    m.reg_start_time = "2012-06-01 17:00:30"
    m.reg_end_time = "2012-06-01 17:00:30"
    m.tm_zone_info = "CST6CDT"
    m.keywords = "latitude longitude tester"
    m.city = "Agawam"
    m.category_id = 1
    m.specific_organization = SpecificOrganization.find(101)
    m.mime_type = nil
    m.postal_code = "01030"
    m.country_id = 1
    m.state_id = 1
    # added (publish_off check added to meeting_test)
    m.contact_email = "fred@test.com"
    m.uid = 1
    m.save!
    m1 = Meeting.find_by_title("Lat/Lon Tester")
    assert_equal "Lat/Lon Tester", m1.title

    # We should be able to search and find the meeting
    m1.latitude = 42.0710458
    m1.longitude = -72.6742455
    m1.save!
    # The ones we just set should get returned by the _for_mapping properties
    assert_equal(42.0710458, m1.latitude_for_mapping)
    assert_equal(-72.6742455, m1.longitude_for_mapping)
    results = Meeting.search({ 'geo_search'=>'01030', 'geo_distance'=>'10' })
    assert_equal(results.length, 1)
    assert_equal("Lat/Lon Tester", results[0].title)

    # Then, if we move it, it should not show up in the results
    m1.latitude = 37.7763
    m1.longitude = -122.2626
    m1.save!
    # The ones we just set should get returned by the _for_mapping properties
    assert_equal(37.7763, m1.latitude_for_mapping)
    assert_equal(-122.2626, m1.longitude_for_mapping)
    results = Meeting.search({ 'geo_search'=>'01030', 'geo_distance'=>'10' })
    assert_equal(results.length, 0)

    # Then, we should be able to find it if it has user overrides
    m1.user_override_latitude = 42.0710458
    m1.user_override_longitude = -72.6742455
    m1.save!
    # The ones we just set should get returned by the _for_mapping properties
    assert_equal(42.0710458, m1.latitude_for_mapping)
    assert_equal(-72.6742455, m1.longitude_for_mapping)
    assert_not_nil(m1.latitude)
    assert_not_nil(m1.longitude)
    results = Meeting.search({ 'geo_search'=>'01030', 'geo_distance'=>'10' })
    assert_equal(results.length, 1)
    assert_equal("Lat/Lon Tester", results[0].title)
    
  end

end
