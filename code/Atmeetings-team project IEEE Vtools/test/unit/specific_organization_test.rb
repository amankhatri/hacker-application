require File.dirname(__FILE__) + '/../test_helper'

class SpecificOrganizationTest < ActiveSupport::TestCase
  # fixtures :regions, :sections, :organizations; :specific_organizations

  def test_check_section_display_name
    org = SpecificOrganization.find( 1598 )
    assert_equal("", org.display_name )
  end

  def test_check_region_display_name
    org = SpecificOrganization.find( 2118)
    assert_equal("", org.display_name )
  end

  def test_check_section_file_string
    org = SpecificOrganization.find( 1598 )
    assert_equal("", org.file_string )
  end

  def test_check_region_file_string
    org = SpecificOrganization.find( 2118 )
    assert_equal("", org.file_string )
  end

  def test_check_character_file_string
    org = SpecificOrganization.find( 993)
    assert_equal('AP03~AES10~MTT17', org.file_string)
  end

  def test_active_states

    org = SpecificOrganization.find(1878)

    # with nil for deactivated it should be active
    assert_not_nil(org.activated)
    assert(org.activated < Time.now)
    assert_nil(org.deactivated)
    assert(org.is_active?)
    # (also should have been active a short time ago)
    assert(org.was_active_during?(10.days))

    # with deactivated in the future it should be active
    org.deactivated = Time.now + 3.days
    assert_not_nil(org.deactivated)
    assert(org.deactivated > Time.now)
    assert(org.is_active?)
    # (also should have been active a short time ago)
    assert(org.was_active_during?(10.days))

    # with deactivated in the past it should not be active
    org.deactivated = Time.now - 3.days
    assert_not_nil(org.deactivated)
    assert(org.deactivated < Time.now)
    assert(!org.is_active?)
    # (but should have been active before that)
    assert(org.was_active_during?(10.days))

    # with activated and deactivated inside of the timespan we're asking about,
    # should still show up as active
    org.activated = Time.now - 2.years
    org.deactivated = Time.now - 1.year
    assert_not_nil(org.deactivated)
    assert(!org.is_active?)
    # (but should have been active before that)
    assert(org.was_active_during?(3.years))

    # also for no deactivated (currently active)
    org.activated = Time.now - 2.years
    org.deactivated = nil
    assert_nil(org.deactivated)
    assert(org.is_active?)
    # (but should have been active before that)
    assert(org.was_active_during?(3.years))

  end


end
