# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Atmeetings::Application.initialize!


################ Items from environment.rb in vTools.Meetings

MAXPICTURESIZEKB = 100  # 100KB
MAXPICTURESIZE = MAXPICTURESIZEKB * 1024
DONTCHANGEPASSWORD = 'Do not Change The Password!!!!IEEE'

# Role Mapping
# bit 0 - Member
# bit 1 - Student Branch
# bit 2 - Chapter
# bit 3 - Affinity Group
# bit 4 - Subsection
# bit 5 - Section
# bit 6 - Council
# bit 7 - A Region Committee
# bit 8 - Region
# bit 9-14 unused
# bit 15 - perhaps "admin"

GUEST = 0
MEMBERNOTVOL = 1
SSECTIONVOL = 63  # everything Section and below
SREGIONVOL = 511  # everything Region and below
ADMIN = 65535

ROLECOLLECTION = { GUEST => "Guest",
                   MEMBERNOTVOL => "Member Only",
                   SSECTIONVOL => "Section Volunteer",
                   SREGIONVOL => "Region Volunteer",
                   ADMIN => "Administrator"
                 }

# Used by RegistrationFeeLevelRestrictionChecker to verify price level
# eligibility restrictions by member grade
IEEE_MEMBER_GRADES = [
  'Affiliate',
  'Associate Member',
  'Fellow',
  'Graduate Student Member',
  'Honorary Member',
  'Life Fellow',
  'Life Member',
  'Life Senior',
  'Member',
  'Senior Member',
  'Student Member',
]

# signal that there is no registration limit
NOREGISTRATIONLIMIT = 99999

# datetime_selects need to start from earliest year that might be in database
# to avoid a problem with the case that the user brings up meeting and hits "change"
# rather than cancel.

EARLIESTYEAR = 2007;

class String
  def integer?
    Integer(self)
    return true
  rescue ArgumentError
    return false
  end
end

# Add convenience method to Array to facilitate building conditions in searches
class Array
  def add_condition! (condition, conjunction = 'AND')
    if String === condition
      add_condition!([condition])
    elsif Hash === condition
      add_condition!([condition.keys.map { |attr| "#{attr}=?" }.join(' AND ')] + condition.values)
    elsif Array === condition
      self[0] = "(#{self[0]}) #{conjunction} (#{condition.shift})" unless empty?
      (self << condition).flatten!
    else
      raise "don't know how to handle this condition type"
    end
    self
  end
end
