class State < ActiveRecord::Base
  belongs_to :country
  has_many :speakers
  has_many :meetings
  has_many :meeting_reports

  validates_presence_of :abbreviation, :name
  validate :country_must_exist
  validates_associated :country

  def country_must_exist
    errors.add(:country, "must be specified") if country_id.nil? || country_id == ""
    errors.add(:country, "must refer to an existing country") if country_id && country.nil?
  end

  def self.per_page
    50
  end

  def self.search(search, page)
    paginate :per_page=>20, :page=>page,
            :select =>"states.*",
            :conditions=>['states.name like ?', "%#{search}%"],
            :speakers=>'name'
  end
end
