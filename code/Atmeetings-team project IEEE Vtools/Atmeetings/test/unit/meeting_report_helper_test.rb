require File.dirname(__FILE__) + '/../test_helper'

class MeetingReportHelperTest < ActiveSupport::TestCase
  # fixtures :meeting_reports

  def setup
    @helper = Object.new.extend(MeetingReportHelper)
    @columns = MeetingReport.search_results_columns
  end

  # To simulate params[:object] use
  #  helper.params = {:object => "Blah"}'
  # To simulate @price use
  #  helper.instance_variable_set(:@price,1000)

  def test_sorted_by_info

    assert_not_nil @helper
    assert_not_nil @columns



  end

  def test_search_results_header

  end

  def test_search_results_row

  end
end
