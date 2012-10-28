require 'digest/sha2'

class LdapUser < ActiveRecord::Base
  belongs_to :section
  has_many :meetings
  has_many :meeting_reports
  
  attr_accessor :password

  validates_uniqueness_of :user_name
  validates_presence_of :user_name, :password

  before_update :keep_admin_admin
  before_save :hash_password
  before_destroy :dont_destroy_admin

  def after_save 
    @password = nil   # for security
  end

# set section id when furnished geocode (use nil if unsuccessful)  
  def section_geocode=(geocode)
    self.section = Section.find_by_geocode( geocode )
  end

# used by admin/login
  def self.authenticate(username, pw)
    user = LdapUser.find(:first, :conditions => ["user_name = ?", username])
    if user.blank? || Digest::SHA256.hexdigest(pw + user.password_salt) != user.password_hash
      user = nil
    end
    user
  end

# used by main/login (with Siteminder in front)
  def self.establish_user(web_account, display_name, member_number, section_geocode, 
                          local_volunteer = true, role = SSECTIONVOL, email = nil)
    # TBD ensure items are not blank/nil
    
    user = LdapUser.find(:first, :conditions => ['user_name = ?', web_account])
    
    # if new user, add them to system before returning
    if ! user
      user = LdapUser.new
      user.user_name = web_account
      user.email = email
      user.display_name = display_name
      # fake a password, won't be used if Siteminder is handling
      user.password = [Array.new(10){rand(256).chr}.join].pack("m").chomp
      user.role = role
      user.member_number = member_number
      user.section_geocode= section_geocode    ## uses method above
      user.save!
    else
      # set the following anyway in case they have changed since user 
      # last visited.
      # user.user_name = web_account  (key)
      user.password = DONTCHANGEPASSWORD
      user.member_number = member_number
      user.email = email
      user.display_name = display_name
      if role == ADMIN
        # admin
        # do nothing
      elsif ( section_geocode && user.section != nil && user.section.geocode && (user.section.geocode == section_geocode) )
        # sticky roles
        user.role |= role
      else
        # New data since they have moved
        user.section_geocode= section_geocode    ## uses method above
        user.role = role
      end
      user.save!
    end
    user
  end
  
  # if there is not an administrative account named !admin, make one
  def self.make_admin_if_none
    if ! self.find_by_user_name("!admin")
      # tbd make sure a role named admin exists
      admin = LdapUser.new( :user_name => "!admin", :password => "!admin", :role => ADMIN)
      admin.save!
    end
  end

  def self.per_page
    50
  end

  def self.search(search, page)
    paginate :per_page=>20, :page=>page,
            :select =>"ldap_users.*",
            :conditions=>['ldap_users.user_name like ?', "%#{search}%"],
            :speakers=>'user_name'
  end

private

  def dont_destroy_admin
    raise "Can't destroy admin" if self.user_name == "!admin"
  end

  def keep_admin_admin
    user = LdapUser.find(self.id)
    if user.user_name == "!admin"
      # make sure admin name isn't changed
      raise "Can't change !admin user name"  if self.user_name != "!admin"
      # make sure admin role isn't changed
      raise "Can't change admin role"  if self.role != ADMIN
    end
  end

  def hash_password
    if self.password != DONTCHANGEPASSWORD
      # Salt makes it much harder to guess passwords by brute force.
      salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
      self.password_salt = salt
      self.password_hash = Digest::SHA256.hexdigest(password+salt)
    end
  end
end
