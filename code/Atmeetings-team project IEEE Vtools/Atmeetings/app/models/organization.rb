class Organization < ActiveRecord::Base
  has_many :specific_organizations
  has_many :sections, :through => :specific_organizations
  has_many :meetings, :through => :specific_organizations
  has_many :meeting_reports, :through => :specific_organizations
  
  def self.per_page
    50
  end

  # name of specific organization fixing Section/Region Mapping
  def display_name
    if self.name == "(region)"
      #  "Region"
      ""
    elsif self.name == "(section)"
      #  "Section"
      ""
    else
      self.name
    end
  end

  # name of specific organization with only file system friendly letters
  def file_string
    str1 = self.name
    # str1.gsub!("(region)", "region")
    str1 = "" if str1 == "(region)"
    # str1.gsub!("(section)", "section")
    str1 = "" if str1 == "(section)"
    str1.gsub!(" ", '_')
    str1.gsub!("/","~")
    str1.gsub!("\(", "")
    str1.gsub!("\)", "")
    str1
  end
  
end
