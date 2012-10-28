class RegistrationFeeLevel < ActiveRecord::Base
  belongs_to :registration_fee
  has_many :meeting_registrations

  validates_presence_of :name
  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  validates_numericality_of :tax_percent, :less_than_or_equal_to => 100, :greater_than => 0, :allow_nil => true
  validates_uniqueness_of :name, :scope => [:registration_fee_id]

  DEFAULT_NAME = 'default'

  def during_active_period?(time = Time.zone.now)
    return false if !self.start_time.blank? and time < self.start_time
    return false if !self.end_time.blank? and time > self.end_time
    return true
  end

  # Methods to deal with meeting-local time zones. All dates/times are stored
  # in the database in UTC. But, we want them to be displayed in the meeting's
  # timezone.
  def start_time
    val = read_attribute(:start_time)
    return val if val.nil?
    time_zone = (!self.registration_fee.nil? and
      !self.registration_fee.meeting.nil? and
      !self.registration_fee.meeting.tm_zone_info.nil?) ?
      self.registration_fee.meeting.tm_zone_info : Meeting::DEFAULT_TIMEZONE

    val.in_time_zone(time_zone)
  end

  # May receive ActiveSupport::TimeWithZone or a string representing the date
  def start_time=(date)
    val = nil
    time_zone = (!self.registration_fee.nil? and
      !self.registration_fee.meeting.nil? and
      !self.registration_fee.meeting.tm_zone_info.nil?) ?
      self.registration_fee.meeting.tm_zone_info : Meeting::DEFAULT_TIMEZONE

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
    write_attribute(:start_time, val)
  end

  def end_time
    val = read_attribute(:end_time)
    return val if val.nil?
    time_zone = (!self.registration_fee.nil? and
      !self.registration_fee.meeting.nil? and
      !self.registration_fee.meeting.tm_zone_info.nil?) ?
      self.registration_fee.meeting.tm_zone_info : Meeting::DEFAULT_TIMEZONE

    val.in_time_zone(time_zone)
  end

  # May receive ActiveSupport::TimeWithZone or a string representing the date
  def end_time=(date)
    val = nil
    time_zone = (!self.registration_fee.nil? and
      !self.registration_fee.meeting.nil? and
      !self.registration_fee.meeting.tm_zone_info.nil?) ?
      self.registration_fee.meeting.tm_zone_info : Meeting::DEFAULT_TIMEZONE

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
    write_attribute(:end_time, val)
  end

  def requires_verification?
    RegistrationFeeLevelRestrictionChecker.instance.requires_verification?(self)
  end

  protected
  def validate
    unless start_time.nil? or end_time.nil? or start_time <= end_time
      errors.add_to_base('price level end time must be after begin time')
    end
    unless restriction.nil? or RegistrationFeeLevelRestrictionChecker.instance.valid_restriction_keys.include?(restriction)
      errors.add(:restriction, 'invalid restriction name')
    end
  end

  # MeetingController.create() and update() save an object graph with new price
  # levels inside a new registration fee (currently the code just creates new
  # fee and level objects on edit). The Rails framework runs model object
  # validation code before attempting any database inserts. So, when create-time
  # validations are run on new price levels neither the parent registration fee
  # object, nor sibling price levels have been persisted yet. Because of this,
  # the validates_uniqueness_of validation, which looks for duplicates in the
  # database, will not correctly detect an attempt to create a registration fee
  # that has multiple price levels with the same name. Hence, it is necessary
  # to check the values in the object graph that will be persisted.
  def validate_on_create
    fee = self.registration_fee
    return if fee.nil?
    fee.registration_fee_levels.each do |x|
      next if x == self
      next if x.name != self.name
      errors.add_to_base('price level descriptions must be unique')
    end
  end
end
