class SpecificOrganization < ActiveRecord::Base
  belongs_to :organization
  belongs_to :section
  has_many :meetings
  has_many :meeting_reports

   def self.per_page
     50
   end

   # name of specific organization fixing Section/Region Mapping
   def display_name
     if self.organization.name == "(section)"
       # "#{self.section.name} SECTION"
       ""
     elsif self.organization.name == "(region)"
       # "REGION #{self.section.region.name}"
       ""
     else
       self.organization.name
     end
   end

   # name of specific organization with only file system friendly letters
   def file_string
     str1 = self.display_name
     str1.gsub!(" ", '_')
     str1.gsub!("/","~")
     str1.gsub!("\(", "")
     str1.gsub!("\)", "")
     str1
   end

   # is_active if activated is before current date/time, and deactivated is either not defined or after current date/time
   def is_active?(time=Time.now)
     return (
              (self.activated < time) &&
              (
                (self.deactivated.blank?) ||
                (self.deactivated > time)
              )
            )
   end

   # whether this was active during the timespan of (Time.now-timespan) to (Time.now)
   def was_active_during?(timespan)
     # First range is from the timespan ago until right now
     during_end = Time.now
     during_start = during_end - timespan
     # Second range is the activated and deactivated (possibly null) for this
     active_start = self.activated
     active_end = self.deactivated || (Time.now+2000.years)

     return (
              ( (during_start < active_start) && (active_start < during_end) ) ||
              ( (during_start < active_end) && (active_end <= during_end) ) ||
              ( (active_start < during_start) && (during_start < active_end) ) ||
              ( (active_start < during_end) && (during_end <= active_end) )
            )
   end

end