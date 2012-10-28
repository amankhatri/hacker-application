class AlertType < ActiveRecord::Base
  has_many :alerts

  def self.per_page
    50
  end

  def self.search(search, page)
    paginate :per_page=>20, :page=>page,
            :select =>"alert_types.*",
            :conditions=>['alert_types.name like ?', "%#{search}%"],
            :speakers=>'name'
  end
end
