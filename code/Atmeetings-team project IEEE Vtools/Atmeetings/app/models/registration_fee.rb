class RegistrationFee < ActiveRecord::Base
  AT_REGISTRATION = 'registration'
  AT_MEETING = 'meeting'
  DEFAULT_CURRENCY = 'USD'

  belongs_to :meeting
  has_many :registration_fee_levels, :dependent => :destroy, :autosave => true
 
  validates_presence_of :currency
  validates_presence_of :merchant_acct
  validates_inclusion_of :allow_at_meeting, :in => [true, false]
  validates_inclusion_of :optional, :in => [true, false]
  validates_inclusion_of :refundable, :in => [true, false]

  # Discourage changing merchant_acct or currency after creation
  # of a registration fee. Instead, the old registration fee should be
  # deleted and replaced with a new fee. Attempts to change these
  # properties will not throw and exception but they will not persist
  # to the database upon save.
  attr_readonly :merchant_acct, :currency

  def require_payment_at_registration?
    !self.allow_at_meeting?
  end

  def single_level?
    self.registration_fee_levels.size == 1
  end

  # Simple builder method to make sure merchant acct and currency get set.
  def self.create_fee(merchant_acct, currency)
    RegistrationFee.new(:merchant_acct => merchant_acct, :currency => currency)
  end

  # Methods to deal with meeting-local time zones. All dates/times are stored in
  # the database in UTC. Normally dates/times are converted to/from server's
  # default timezone automatically. But, we want them to be displayed in the
  # meeting's timezone. We can't just set a new value for Time.zone at the
  # beginning of a controller action (as is done when display timezones are
  # 'per-user'). So, override the default accessor methods provided by
  # ActiveRecord. The getter first reads from the database (result will be in
  # server's default timezone), then converts to meeting's timezone. Setters use
  # the meeting's timezone to parse the date string provided in request
  # parameters when the user creates/edits the meeting. 
  def refund_cutoff
    val = read_attribute(:refund_cutoff)
    return val if val.nil?
    time_zone = (!self.meeting.blank? and !self.meeting.tm_zone_info.blank?) ?
      self.meeting.tm_zone_info : Meeting::DEFAULT_TIMEZONE

    val.in_time_zone(time_zone)
  end

  # May receive ActiveSupport::TimeWithZone or a string representing the date
  def refund_cutoff=(date)
    val = nil
    time_zone = (!self.meeting.blank? and !self.meeting.tm_zone_info.blank?) ?
      self.meeting.tm_zone_info : Meeting::DEFAULT_TIMEZONE

    if date.respond_to?(:acts_like_time?) and date.acts_like_time?
      val = date.in_time_zone(time_zone)
    else
      tz = ActiveSupport::TimeZone[time_zone]
      # Originally this next step was not here, and we went directly down to 'Pull from TZInfo,...'
      #  But there are some edge cases where that fallback did not suffice (for example, when selected
      #  time zone was America/New_York, and Daylight Savings was on, then the UTC offset was 4 hours,
      #  which returned the TimeZone for Atlantic Time (Canada)(GMT-04:00) and ended up making the
      #  date that resulted be an hour before what was submitted.
      # So here we will make another attempt to get the TimeZone using the name, but the name that we
      #  have here is the TZInfo identifier (like 'America/New_York') as opposed to the ActiveSupport::
      #  TimeZone name (which would be like 'Eastern Time (US & Canada)').  So we need to iterate over
      #  the mapping that exists within ActiveSupport::TimeZone and match the name we have with the
      #  VALUE of the mapping hash entry, and the KEY will then be the name that we want.
      if (tz.nil?)
        ActiveSupport::TimeZone::MAPPING.each { |key,value|
          if (value.casecmp(time_zone) == 0)
            tz = ActiveSupport::TimeZone[key]
          end
        }
      end
      # If we STILL don't have a TimeZone: Pull from TZInfo,
      # then get corresponding ActiveSupport timezone using the UTC offset
      if tz.nil?
        tz = ActiveSupport::TimeZone[
          TZInfo::Timezone.get(time_zone).current_period.utc_total_offset]
      end
      val = tz.parse(date.to_s)
    end
    write_attribute(:refund_cutoff, val)
  end

  # Validation method
  protected
  def validate
    unless self.registration_fee_levels.size > 0
      errors.add_to_base('must have at least one price level')
    end

    RegistrationFeeValidations.validates_price_level_date_ranges(self)
  end
end
