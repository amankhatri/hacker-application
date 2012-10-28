class Section < ActiveRecord::Base
  # belongs_to :region
  # has_many :specific_organizations
  # has_many :organizations, :through => :specific_organizations

  belongs_to :region
  has_many :ldap_users
  has_many :specific_organizations
  has_many :organizations, :through => :specific_organizations

  def self.per_page
    50
  end

  def display_name
    if self.name != "(region)"
      "#{name} SECTION"
    else
      "REGION #{self.region.name}"
    end
  end
  
  def file_string
    str1 = name
    str1 = "region-#{self.region.name}" if self.name == "(region)"
    str1.gsub!(" ", '_')
    str1.gsub!("/","~")
    str1.gsub!("\(", "")
    str1.gsub!("\)", "")
    str1
  end
end