class Country < ActiveRecord::Base
  has_many :states, :dependent => :destroy
  has_many :meetings
  has_many :meeting_reports

  validates_presence_of :abbreviation, :name
  validates_uniqueness_of :abbreviation, :name

  def self.per_page
    50
  end

  def self.search(search, page)
    paginate :per_page=>20, :page=>page,
            :select =>"countries.*",
            :conditions=>['countries.name like ?', "%#{search}%"],
            :speakers=>'name'
  end
end
