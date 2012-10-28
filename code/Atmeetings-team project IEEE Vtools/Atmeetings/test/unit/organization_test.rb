require File.dirname(__FILE__) + '/../test_helper'

class OrganizationTest < ActiveSupport::TestCase
  # fixtures :organizations

  # Replace this with your real tests.
  def test_check_section_display_name
    org = Organization.new( :name => "(section)" )
    assert_equal("", org.display_name )
  end
  
  def test_check_region_display_name
    org = Organization.new( :name => "(region)" )
    assert_equal("", org.display_name )
  end
  
  def test_check_section_file_string
    org = Organization.new( :name => "(section)" )
    assert_equal("", org.file_string )
  end
  
  def test_check_region_file_string
    org = Organization.new( :name => "(region)" )
    assert_equal("", org.file_string )
  end
  
  def test_check_character_file_string
    org = Organization.new( :name => 'I/We/You work (at least sometimes)')
    assert_equal('I~We~You_work_at_least_sometimes', org.file_string)
  end
  
end
