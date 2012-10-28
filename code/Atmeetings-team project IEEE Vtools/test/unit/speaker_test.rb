require File.dirname(__FILE__) + '/../test_helper'

class SpeakerTest < ActiveSupport::TestCase
  # fixtures :speakers

  def test_has_info?
    s = Speaker.find(1)   # no fields
    assert ! s.has_info?
    s = Speaker.find(2)   # has a display_name
    assert s.has_info?
    s = Speaker.find(3)   # has a topic
    assert s.has_info?
  end
  
  def test_require_all_names_if_any
    s = Speaker.new
    s.first_name = "First"
    s.meeting_id = 7
    assert !s.save, "If First Name, then Last Name, and Display Name required"
    s.last_name = "Last"
    assert !s.save, "If First Name and Last Name, then Display Name required"
    s.display_name ="Dr. First Last, P.E."
    assert s.save, "With all three, things can be saved"
  end
  
  def test_accept_speaker_with_only_display
    s = Speaker.new
    s.meeting_id = 7
    s.display_name ="Dr. First Last, P.E."
    assert s.save, "With just display_name, things can be saved"
  end
  
  def test_length_of_topic
    s = Speaker.find(1)
    s.topic = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
    assert s.save, "120 chars are saved"
    s.topic = "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567891"
    assert !s.save, "121 chars cannot be saved"
  end
end
