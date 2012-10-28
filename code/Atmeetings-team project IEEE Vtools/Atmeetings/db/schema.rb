# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120726172815) do

  create_table "alert_types", :force => true do |t|
    t.text "name", :null => false
  end

  create_table "alerts", :force => true do |t|
    t.integer  "alert_type_id", :default => 0, :null => false
    t.integer  "meeting_id",    :default => 0, :null => false
    t.integer  "ldap_user_id",  :default => 0, :null => false
    t.text     "email_address",                :null => false
    t.integer  "hours_before"
    t.datetime "alarm_time"
  end

  add_index "alerts", ["alert_type_id"], :name => "fk_alerts_alert_type"
  add_index "alerts", ["ldap_user_id"], :name => "fk_alerts_ldap_user"
  add_index "alerts", ["meeting_id"], :name => "fk_alerts_meeting"

  create_table "allowed_ips", :force => true do |t|
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "awards", :force => true do |t|
    t.string   "award_winners"
    t.string   "award_name"
    t.text     "description"
    t.date     "recieved_on"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "categories", :force => true do |t|
    t.string "name", :limit => 64, :default => "", :null => false
  end

  create_table "countries", :force => true do |t|
    t.string "abbreviation", :limit => 64, :default => "", :null => false
    t.string "name",         :limit => 64, :default => "", :null => false
  end

  create_table "current_meetings", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "engine_schema_info", :id => false, :force => true do |t|
    t.string  "engine_name"
    t.integer "version"
  end

  create_table "label_texts", :force => true do |t|
    t.integer  "pdf_sheet_id"
    t.string   "table"
    t.string   "attribute"
    t.integer  "font_size"
    t.string   "type_face"
    t.string   "font_color"
    t.integer  "row_no"
    t.boolean  "all_caps"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ldap_users", :force => true do |t|
    t.string   "user_name",     :limit => 128, :default => "", :null => false
    t.string   "email",         :limit => 128
    t.string   "password_hash",                :default => "", :null => false
    t.string   "password_salt",                :default => "", :null => false
    t.string   "member_number"
    t.string   "display_name"
    t.string   "section_id"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "role"
  end

  create_table "meeting_registrations", :force => true do |t|
    t.integer  "ldap_user_id"
    t.integer  "meeting_id",                                 :default => 0,  :null => false
    t.string   "first_name",                  :limit => 32,  :default => "", :null => false
    t.string   "last_name",                   :limit => 32,  :default => "", :null => false
    t.string   "address1",                    :limit => 64,  :default => "", :null => false
    t.string   "address2",                    :limit => 64
    t.string   "city",                        :limit => 64,  :default => "", :null => false
    t.integer  "country_id",                                 :default => 0,  :null => false
    t.integer  "state_id",                                   :default => 0,  :null => false
    t.string   "postal_code",                 :limit => 64,  :default => ""
    t.string   "email",                       :limit => 64,  :default => "", :null => false
    t.string   "menu",                        :limit => 64,  :default => "", :null => false
    t.string   "phone",                       :limit => 32
    t.string   "member_number"
    t.integer  "registration_fee_invoice_id"
    t.integer  "registration_fee_level_id"
    t.string   "amount",                      :limit => 8
    t.datetime "created_at"
    t.boolean  "cancelled"
    t.string   "special_requests",            :limit => 500
    t.boolean  "present"
    t.boolean  "interested"
  end

  add_index "meeting_registrations", ["ldap_user_id", "meeting_id"], :name => "ldap_user_id"

  create_table "meeting_reports", :force => true do |t|
    t.integer  "specific_organization_id"
    t.integer  "category_id"
    t.integer  "meeting_id"
    t.string   "city",                     :limit => 128
    t.integer  "state_id"
    t.integer  "country_id"
    t.text     "title",                                                       :null => false
    t.text     "description"
    t.integer  "description_type",                         :default => 0
    t.boolean  "cost",                                     :default => false
    t.text     "cosponsor_name"
    t.text     "keywords"
    t.integer  "ieee_attending",                           :default => 0
    t.integer  "guests_attending",                         :default => 0
    t.text     "contact_email"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "tm_zone_info",             :limit => 128
    t.string   "submitter",                                                   :null => false
    t.string   "submitter_email",          :limit => 50
    t.string   "email_cc_list",            :limit => 50
    t.string   "submitter_ip",             :limit => 15
    t.string   "comment",                  :limit => 1024
    t.string   "result",                   :limit => 15
    t.boolean  "joint_with_branch",                        :default => false
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  add_index "meeting_reports", ["category_id"], :name => "fk_meeting_reports_category"
  add_index "meeting_reports", ["country_id"], :name => "fk_meeting_reports_country"
  add_index "meeting_reports", ["meeting_id"], :name => "fk_meeting_reports_meeting"
  add_index "meeting_reports", ["specific_organization_id"], :name => "fk_meeting_reports_specific_organization"
  add_index "meeting_reports", ["state_id"], :name => "fk_meeting_reports_state"

  create_table "meetings", :force => true do |t|
    t.integer  "specific_organization_id"
    t.integer  "category_id"
    t.string   "address1",                  :limit => 128
    t.string   "address2",                  :limit => 128
    t.string   "city",                      :limit => 128
    t.integer  "state_id"
    t.integer  "country_id"
    t.string   "postal_code",               :limit => 64
    t.text     "map_url"
    t.float    "longitude"
    t.float    "latitude"
    t.text     "title",                                                            :null => false
    t.text     "description"
    t.integer  "description_type",                              :default => 0
    t.string   "building",                  :limit => 128
    t.string   "room_number",               :limit => 48
    t.text     "registration_url"
    t.text     "survey_url"
    t.boolean  "cost",                                          :default => false
    t.binary   "picture",                   :limit => 16777215
    t.text     "header"
    t.text     "footer"
    t.text     "cosponsor_name"
    t.text     "keywords"
    t.text     "contact_email"
    t.text     "contact_display"
    t.integer  "contact_display_type",                          :default => 0
    t.text     "agenda"
    t.integer  "agenda_type",                                   :default => 0
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "tm_zone_info",              :limit => 128
    t.text     "created_by"
    t.datetime "created_on"
    t.text     "updated_by"
    t.datetime "updated_on"
    t.string   "mime_type"
    t.datetime "reg_start_time"
    t.datetime "reg_end_time"
    t.string   "menu1",                     :limit => 64
    t.string   "menu2",                     :limit => 64,       :default => "",    :null => false
    t.string   "menu3",                     :limit => 64
    t.integer  "creator_ldap_user_id",                          :default => 0,     :null => false
    t.boolean  "joint_with_branch",                             :default => false
    t.boolean  "cancelled"
    t.integer  "max_registrations"
    t.integer  "revision_number",                               :default => 0,     :null => false
    t.string   "uid",                                                              :null => false
    t.string   "section_merchant_acct",     :limit => 32
    t.boolean  "charge"
    t.string   "region_merchant_acct",      :limit => 32
    t.string   "section_merchant_currency", :limit => 8
    t.string   "region_merchant_currency",  :limit => 8
    t.boolean  "publish",                                       :default => true
    t.boolean  "virtual",                                       :default => false
    t.float    "user_override_latitude"
    t.float    "user_override_longitude"
  end

  add_index "meetings", ["category_id"], :name => "fk_meetings_category"
  add_index "meetings", ["country_id"], :name => "fk_meetings_country"
  add_index "meetings", ["specific_organization_id"], :name => "fk_meetings_specific_organization"
  add_index "meetings", ["state_id"], :name => "fk_meetings_state"

  create_table "menus", :force => true do |t|
    t.integer "meeting_id"
    t.string  "name",       :limit => 64
  end

  create_table "organizations", :force => true do |t|
    t.text "name", :null => false
  end

  create_table "pdf_sheets", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.float    "page_width"
    t.float    "page_length"
    t.float    "top_margin"
    t.float    "left_margin"
    t.float    "column_gutter"
    t.float    "row_gutter"
    t.integer  "columns"
    t.float    "badge_width"
    t.float    "badge_height"
    t.integer  "rows_per_page"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", :force => true do |t|
    t.string "name", :limit => 128, :default => "", :null => false
  end

  create_table "registration_fee_invoices", :force => true do |t|
    t.string   "description",    :limit => 64
    t.string   "price",          :limit => 8
    t.string   "currency",       :limit => 8
    t.string   "status",         :limit => 16
    t.datetime "payment_time"
    t.string   "invoice_id",     :limit => 16
    t.datetime "invoice_time"
    t.string   "transaction_id", :limit => 32
  end

  create_table "registration_fee_levels", :force => true do |t|
    t.integer  "registration_fee_id"
    t.string   "name",                :limit => 64
    t.string   "amount",              :limit => 8
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "restriction",         :limit => 32
    t.string   "tax_percent",         :limit => 8
  end

  create_table "registration_fees", :force => true do |t|
    t.integer  "meeting_id"
    t.string   "currency",         :limit => 8
    t.boolean  "allow_at_meeting"
    t.boolean  "optional"
    t.string   "merchant_acct",    :limit => 32
    t.boolean  "refundable"
    t.datetime "refund_cutoff"
  end

  create_table "sections", :force => true do |t|
    t.string  "name",      :limit => 128
    t.integer "region_id",                :default => 0, :null => false
    t.string  "geocode"
  end

  add_index "sections", ["region_id"], :name => "fk_sections_region"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "speaker_reports", :force => true do |t|
    t.string  "first_name",        :limit => 64,  :default => "", :null => false
    t.string  "last_name",         :limit => 64,  :default => "", :null => false
    t.string  "middle_name",       :limit => 64
    t.text    "display_name"
    t.string  "prefix",            :limit => 16
    t.string  "suffix",            :limit => 32
    t.string  "city",              :limit => 128
    t.integer "state_id"
    t.integer "country_id"
    t.string  "email",             :limit => 128
    t.text    "organization"
    t.text    "topic"
    t.boolean "dlp_speaker"
    t.integer "meeting_report_id"
  end

  add_index "speaker_reports", ["country_id"], :name => "fk_speaker_reports_countries"
  add_index "speaker_reports", ["meeting_report_id"], :name => "fk_speaker_reports_meeting"
  add_index "speaker_reports", ["state_id"], :name => "fk_speaker_reports_state"

  create_table "speakers", :force => true do |t|
    t.string  "first_name",             :limit => 64,       :default => "", :null => false
    t.string  "last_name",              :limit => 64,       :default => "", :null => false
    t.string  "middle_name",            :limit => 64
    t.text    "display_name"
    t.string  "prefix",                 :limit => 16
    t.string  "suffix",                 :limit => 32
    t.string  "address1",               :limit => 128
    t.string  "address2",               :limit => 128
    t.string  "city",                   :limit => 128
    t.integer "state_id"
    t.integer "country_id"
    t.string  "postal_code",            :limit => 64
    t.string  "email",                  :limit => 128
    t.binary  "photograph",             :limit => 16777215
    t.text    "biography"
    t.text    "organization"
    t.text    "topic"
    t.binary  "topic_picture",          :limit => 16777215
    t.text    "topic_description"
    t.integer "meeting_id",                                 :default => 0,  :null => false
    t.boolean "dlp_speaker"
    t.text    "speaker_url"
    t.integer "biography_type"
    t.string  "mime_type"
    t.integer "topic_description_type"
  end

  add_index "speakers", ["country_id"], :name => "fk_speakers_countries"
  add_index "speakers", ["meeting_id"], :name => "fk_speakers_meeting"
  add_index "speakers", ["state_id"], :name => "fk_speakers_state"

  create_table "specific_organizations", :force => true do |t|
    t.integer  "organization_id", :default => 0,                     :null => false
    t.integer  "section_id",      :default => 0,                     :null => false
    t.text     "name"
    t.integer  "recid"
    t.integer  "sub_code"
    t.datetime "activated",       :default => '2005-01-01 00:00:00', :null => false
    t.datetime "deactivated"
  end

  add_index "specific_organizations", ["organization_id"], :name => "fk_specificorganizations_organization"
  add_index "specific_organizations", ["section_id"], :name => "fk_specific_organizations_section"

  create_table "states", :force => true do |t|
    t.string  "abbreviation", :limit => 8,  :default => "", :null => false
    t.string  "name",         :limit => 64, :default => "", :null => false
    t.integer "country_id",                 :default => 0,  :null => false
  end

  add_index "states", ["country_id"], :name => "fk_states_countries"

end
