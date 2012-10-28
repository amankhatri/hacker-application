class Category < ActiveRecord::Base
  has_many :meetings
  has_many :meeting_reports
  
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.per_page
    50
  end

  def self.search(search, page)
    paginate :per_page=>20, :page=>page,
            :select =>"categories.*",
            :conditions=>['categories.name like ?', "%#{search}%"],
            :speakers=>'name'
  end

end
