require File.dirname(__FILE__) + '/../test_helper'

class MeetingRegistrationTest < ActiveSupport::TestCase
  # fixtures :ldap_users, :meetings, :countries, :states

  def setup_registration_test
    @m = MeetingRegistration.new
    @m.ldap_user_id = 3
      
    @m.meeting_id = 1
    @m.first_name = "David23232"
    @m.last_name = "Jimmeny"
    @m.address1 = "One Way"
    @m.address2 = "Down There"
    @m.city = "Green River"
    @m.country_id = 3
    @m.state_id = 2
    @m.postal_code = "80001"
    @m.email = "Freddie@dotnet.com"
    @m.menu = "French"
    @m.phone = "1-800-555-1234"
  end
    
    # Test ability to create a new meeting record
  def test_registration_create
    setup_registration_test
    @m.save!

    m1 = MeetingRegistration.find_by_city("Green River")
    
    assert_equal "Jimmeny", m1.last_name

    assert_equal "80001", m1.postal_code

    # these two are supposed to be auto-maintained by Rails but Yaml 
    # load does NOT set them
    MeetingRegistration.destroy(m1.id)
  end

# run all the negative tests
# missing all the required values
  def test_negative_registration_create
    setup_registration_test
    @m.state_id = nil
    assert !@m.save, "state was nil"
    
    setup_registration_test
    @m.country_id = nil
    assert !@m.save, "country was nil"
    
    setup_registration_test
    @m.first_name = nil
    assert !@m.save, "first_name was nil"

    setup_registration_test
    @m.last_name = nil
    assert !@m.save, "last_name was nil"

    setup_registration_test
    @m.city = nil
    assert !@m.save, "city was nil"

    setup_registration_test
    @m.email = nil
    assert !@m.save, "email was nil"

    # Make sure we're validating length of special_requests
    setup_registration_test
    value = ""
    501.times{value  << (65 + rand(25)).chr}
    @m.special_requests = value
    assert !@m.save, "Validation did not reject special_requests > 500 chars (validation errors='" + @m.errors.full_messages.join(',') + "')"

    # check the positive
    setup_registration_test
    assert @m.save, "record was saved"
    MeetingRegistration.destroy(@m.id)
    
  end  
end