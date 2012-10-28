require File.dirname(__FILE__) + '/../test_helper'

class MeetingReportTest < ActiveSupport::TestCase
  # fixtures :meeting_reports
  
  def test_create_report
    assert true
  end

  def test_creating_meeting_report_with_active_and_inactive_specific_organization

    so = SpecificOrganization.find(1870)

    m = MeetingReport.new
    m.title = "test_creating_meeting_report_with_active_and_inactive_specific_organization"
    m.description = "test_creating_meeting_report_with_active_and_inactive_specific_organization"
    m.keywords = "test blah"
    m.specific_organization = so
    m.submitter = "Joe Dirt"
    m.ieee_attending = 4
    m.guests_attending = 4
    m.start_time = Time.now - 10.days
    m.end_time = Time.now - 10.days + 2.hours
    m.category_id = 2
    m.city = "Mobile"
    m.tm_zone_info = "CST6CDT"
    m.country_id = 1
    m.state_id = 1

    so.activated = Time.now + 10.days
    so.deactivated = nil
    so.save!
    m.specific_organization = nil
    m.specific_organization = so

    assert(!m.save, "Should not be able to save with specific organization not active")
    assert_equal("must have been active within three years", m.errors[:specific_organization][0])
    assert(m.new_record?)

    so.activated = Time.now - 4.years
    so.deactivated = Time.now - 3.years - 1.month
    so.save!
    so = SpecificOrganization.find(1870)

    m.specific_organization = nil
    m.specific_organization = so
    assert(!m.save, "Should not be able to save with specific organization not active")
    assert_equal("must have been active within three years", m.errors[:specific_organization][0])

    so.activated = Time.now - 4.years
    so.deactivated = Time.now - 2.years - 10.months
    so.save!
    so = SpecificOrganization.find(1870)

    m.specific_organization = nil
    m.specific_organization = so
    assert(m.save, "Should be able to save with specific organization active within 3 years")

    assert_not_nil(MeetingReport.find_by_title("test_creating_meeting_report_with_active_and_inactive_specific_organization"))
  end

  def test_search

    debug = false # make this true to output bunches of info during test

    assert ((MeetingReport.default_per_page > 1) && (MeetingReport.default_per_page < 20)), "MeetingReport.default_per_page should return a reasonable number (1 < x < 30)"

    total_reports = 11                          # total reports in meeting_reports.yml fixtures
    less_per_page = 3                           # number to test paginating
    order_by = "title"                          # to change the order and get different results
    search_that_can_be_exact = "Test Meeting"   # should have a value is contained in some reports, exact in others
    reports_with_exact = 2                      # number that have 'search_that_can_be_exact' as exact
    category_id = 3                             # the id of a category that a subset of reports have
    category_name = "Administrative"            # the name of the category
    reports_with_category = 6                   # the number that have the category


    cutoff = Time.now - 1.year - 1.month        # a date/time to use to get a subset of reports
    reports_before_cutoff = 5                   # number of reports before cutoff

    params = {}
    results = MeetingReport.search(params)
    assert results.total_entries == total_reports, "This is just to try to make sure that meeting_report_test.rb will get glanced if meeting_reports.yml fixtures are altered"
    assert results.total_entries > results.length, "This should be true as long as the default per_page for search is less than the number of reports in fixtures"
    puts "\nresults.total_entries=" + results.total_entries.to_s unless !debug
    puts "\nresults.length=" + results.length.to_s unless !debug

    # Change :per_page and get different number of results
    params[:per_page] = less_per_page
    results = MeetingReport.search(params)
    assert results.total_entries == total_reports
    assert results.length < results.total_entries
    assert results.length == less_per_page
    order_check_1 = ""
    results.each { |res| order_check_1 += res.id.to_s }
    puts "\norder_check_1=" + order_check_1 unless !debug

    # Change :order and get different order
    params[:order] = order_by
    results = MeetingReport.search(params)
    assert results.total_entries == total_reports
    assert results.length < results.total_entries
    assert results.length == less_per_page
    order_check_2 = ""
    results.each { |res| order_check_2 += res.id.to_s }
    puts "\norder_check_2=" + order_check_2 unless !debug
    assert order_check_1 != order_check_2

    # Get list of result columns, make sure that they are all in results
    result_columns = MeetingReport.search_results_columns
    puts "\nresults.attributes=" + results[0].attributes.to_s unless !debug
    result_columns.each { |res_col|
      puts "\n" + res_col["Key"] unless !debug
      key_as_att = res_col["Key"].gsub(/\./, "_")
      assert results[0].attributes.key?(key_as_att), "All MeetingReportController.search_results_columns should be present in results ('" + key_as_att + "' was not found)"
    }

    # Flip the :use_exact flag and see a difference in results
    params[:search] = search_that_can_be_exact
    results = MeetingReport.search(params)
    assert results.total_entries > reports_with_exact
    params[:use_exact] = "true"
    results = MeetingReport.search(params)
    assert results.total_entries == reports_with_exact

    # Search by category
    params = {}
    params[:category_id] = category_id
    results = MeetingReport.search(params)
    assert results.total_entries = reports_with_category
    results.each { |res|
      res.categories_name = category_name
    }
    
    # Search by society
    # Search by region
    # Search by section
    # Search by organization
    
    # Search by start time
    params = {}
    params[:meeting_before] = cutoff.strftime(MeetingReport.search_datetime_format)
    results = MeetingReport.search(params)
    before_cutoff = results.total_entries
    assert before_cutoff == reports_before_cutoff, "The number of reports before the cutoff (" + cutoff.strftime(MeetingReport.search_datetime_format) + ") should be " + reports_before_cutoff.to_s + ", but was " + before_cutoff.to_s
    params = {}
    params[:meeting_after] = cutoff.strftime(MeetingReport.search_datetime_format)
    results = MeetingReport.search(params)
    after_cutoff = results.total_entries
    assert after_cutoff == (total_reports-reports_before_cutoff), "The number of reports before the cutoff (" + cutoff.strftime(MeetingReport.search_datetime_format) + ") should be " + (total_reports-reports_before_cutoff).to_s + ", but was " + after_cutoff.to_s

    # Search by created on
      
  end
   
end
