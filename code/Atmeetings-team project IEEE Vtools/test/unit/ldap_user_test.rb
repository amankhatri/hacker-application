require File.dirname(__FILE__) + '/../test_helper'

class LdapUserTest < ActiveSupport::TestCase
  # fixtures :ldap_users, :sections

  # Note: LdapUser.authenticate tested in integration tests

  def test_auth 
    #check that we can login we a valid user 
    assert  LdapUser.authenticate("admin", "admin")    
    #wrong username
    assert_nil    LdapUser.authenticate("badadmin", "admin")
    #wrong password
    assert_nil    LdapUser.authenticate("admin", "badpassword")
    #wrong login and pass
    assert_nil    LdapUser.authenticate("badadmin", "badpassword")
  end

  def test_collision
    #check can't create new LdapUser with existing LdapUsername
    u = LdapUser.new
    u.user_name = "admin"
    u.password = "admin"
    assert !u.save
  end


  def test_create
    #check create works and we can authenticate after creation
    u = LdapUser.new
    u.user_name      = "newuser"
    u.password = "mynewpassword"
    u.email = "newuser@newuser.com"  
    assert u.save
    assert_not_nil u.password_salt
    assert_equal 8, u.password_salt.length
    assert_equal u, LdapUser.authenticate(u.user_name, "mynewpassword")

    u = LdapUser.new(:user_name => "newbob", :password => "newpassword", :email => "newbob@mcbob.com" )
    assert u.save 
    assert_not_nil u.password_salt
    assert_not_nil u.password_hash
    assert_equal u, LdapUser.authenticate(u.user_name, "newpassword")
  end

  def test_establish_existing_user
    # test to make sure we find the right existing user 
    # TBD: and we update their information based on supplied info

    display_name = "Frank Jones"
    user = LdapUser.establish_user("Frankie", display_name, '12345678', 'R30001' )
    assert_not_nil(user)
    assert_equal("Frankie", user.user_name)  #TBD - case insensitive?
    assert_equal(display_name, user.display_name)
    assert_equal("R30001", user.section.geocode)
  end

  def test_establish_existing_user_with_new_section
    # test to make sure we find the right existing user 
    # TBD: and we update their information based on supplied info

    display_name = "Frank Jones"
    user = LdapUser.establish_user("Frankie", display_name, '12345678', 'R30003' )
    assert_not_nil(user)
    assert_equal('R30003', user.section.geocode)
  end
  
  def test_establish_new_user_wo_email
    display_name = 'New User'
    user = LdapUser.establish_user('newuser', display_name, '98765432', 'R30001' )
    assert_equal(display_name, user.display_name)
    assert_equal('newuser', user.user_name)
    assert_equal('R30001', user.section.geocode)
    assert_equal('98765432', user.member_number)
    assert_equal(SSECTIONVOL, user.role)
    assert_nil user.email
  end

  def test_establish_new_user_w_email
    display_name = 'New User'
    user = LdapUser.establish_user('newuser', display_name, '98765432', 'R30001', true, SSECTIONVOL, 'newuser@ieee.org' )
    assert_equal(display_name, user.display_name)
    assert_equal('newuser', user.user_name)
    assert_equal('R30001', user.section.geocode)
    assert_equal('98765432', user.member_number)
    assert_equal(SSECTIONVOL, user.role)
    assert_equal('newuser@ieee.org', user.email)
  end
  
  def test_establish_existing_sticky_volunteer
    # make sure that both volunteer and role of creator stick
    display_name = "Frank Jones"
    user = LdapUser.establish_user("Frankie", display_name, '12345678', 'R30001', false, MEMBERNOTVOL )
    assert_equal(SSECTIONVOL, user.role)
  end
  
  def test_establish_become_volunteer
    # make sure that both volunteer and role of creator stick
    display_name = "Sue Smith"
    user = LdapUser.establish_user("Suzie", display_name, '12345688', 'R30001', true, SSECTIONVOL )
    assert_equal(SSECTIONVOL, user.role)
  end

  def test_establish_moved
    # make sure that someone who moves out, has to start over
    display_name = "Joan Smith"
    user = LdapUser.establish_user("Joan", display_name, '88345688', 'R30001', false, MEMBERNOTVOL )
    assert_equal(MEMBERNOTVOL, user.role)
    assert_equal('R30001', user.section.geocode)
  end

end
