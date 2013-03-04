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

ActiveRecord::Schema.define(:version => 20130304134455) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",                   :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.boolean  "super_admin",                          :default => false, :null => false
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "structure_id"
    t.string   "civility"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.boolean  "activated",                            :default => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["invitation_token"], :name => "index_admin_users_on_invitation_token"
  add_index "admin_users", ["invited_by_id"], :name => "index_admin_users_on_invited_by_id"
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "audiences", :force => true do |t|
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "audiences", ["name"], :name => "index_audiences_on_name"

  create_table "audiences_courses", :id => false, :force => true do |t|
    t.integer "audience_id"
    t.integer "course_id"
  end

  add_index "audiences_courses", ["audience_id", "course_id"], :name => "audience_course_index"

  create_table "book_tickets", :force => true do |t|
    t.integer  "number"
    t.decimal  "price"
    t.string   "validity"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.string   "no_result_image_file_name"
    t.string   "no_result_image_content_type"
    t.integer  "no_result_image_file_size"
    t.datetime "no_result_image_updated_at"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "slug"
  end

  add_index "cities", ["slug"], :name => "index_cities_on_slug", :unique => true

  create_table "courses", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "frequency"
    t.text     "description"
    t.boolean  "is_promoted",                 :default => false
    t.boolean  "has_online_payment",          :default => false
    t.text     "info"
    t.text     "registration_date"
    t.boolean  "is_individual"
    t.boolean  "is_for_handicaped"
    t.text     "trial_lesson_info"
    t.text     "price_details"
    t.text     "price_info"
    t.text     "conditions"
    t.text     "partner_rib_info"
    t.boolean  "audition_mandatory"
    t.text     "refund_condition"
    t.boolean  "can_be_joined_during_year"
    t.integer  "structure_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "slug"
    t.string   "homepage_image_file_name"
    t.string   "homepage_image_content_type"
    t.integer  "homepage_image_file_size"
    t.datetime "homepage_image_updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "place_id"
  end

  add_index "courses", ["place_id"], :name => "index_courses_on_place_id"
  add_index "courses", ["slug"], :name => "index_courses_on_slug", :unique => true
  add_index "courses", ["type"], :name => "index_courses_on_type"

  create_table "courses_levels", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "level_id"
  end

  add_index "courses_levels", ["level_id", "course_id"], :name => "index_courses_levels_on_level_id_and_course_id"

  create_table "courses_subjects", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "subject_id"
  end

  add_index "courses_subjects", ["course_id", "subject_id"], :name => "index_courses_subjects_on_course_id_and_subject_id"

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "levels", :force => true do |t|
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "levels", ["name"], :name => "index_levels_on_name"

  create_table "newsletter_users", :force => true do |t|
    t.string   "city"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "street"
    t.text     "info"
    t.string   "zip_code"
    t.boolean  "has_handicap_access"
    t.integer  "nb_room"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_mobile_phone"
    t.string   "contact_email"
    t.integer  "structure_id"
    t.integer  "city_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.boolean  "has_cloackroom",       :default => false
    t.boolean  "has_internet",         :default => false
    t.boolean  "has_air_conditioning", :default => false
    t.boolean  "has_swimming_pool",    :default => false
    t.boolean  "has_free_parking",     :default => false
    t.boolean  "has_jacuzzi",          :default => false
    t.boolean  "has_sauna",            :default => false
    t.boolean  "has_daylight",         :default => false
  end

  create_table "plannings", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.date     "day_one"
    t.time     "day_one_start_time"
    t.time     "day_one_duration"
    t.date     "day_two"
    t.time     "day_two_start_time"
    t.time     "day_two_duration"
    t.date     "day_three"
    t.time     "day_three_start_time"
    t.time     "day_three_duration"
    t.date     "day_four"
    t.time     "day_four_start_time"
    t.time     "day_four_duration"
    t.date     "day_five"
    t.time     "day_five_start_time"
    t.time     "day_five_duration"
    t.integer  "week_day"
    t.time     "start_time"
    t.time     "end_time"
    t.time     "duration"
    t.boolean  "class_during_holidays"
    t.decimal  "promotion"
    t.integer  "nb_place_available"
    t.text     "info"
    t.string   "teacher_name"
    t.integer  "max_age_for_kid"
    t.integer  "min_age_for_kid"
    t.integer  "course_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "plannings", ["week_day"], :name => "index_plannings_on_week_day"

  create_table "prices", :force => true do |t|
    t.string   "libelle"
    t.decimal  "amount"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "registration_fees", :force => true do |t|
    t.decimal  "price"
    t.boolean  "for_kid"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "renting_rooms", :force => true do |t|
    t.string   "name"
    t.integer  "surface"
    t.text     "info"
    t.integer  "regular_renting_price"
    t.integer  "minimum_price"
    t.integer  "maximum_price"
    t.text     "price_info"
    t.text     "contact_mail"
    t.text     "contact_phone"
    t.boolean  "is_duty_free"
    t.boolean  "has_recording_studio"
    t.boolean  "has_cloakroom"
    t.boolean  "has_bars"
    t.boolean  "has_mirrors"
    t.boolean  "has_sound"
    t.boolean  "has_carpets"
    t.boolean  "has_parquet"
    t.boolean  "has_piano"
    t.integer  "structure_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "structures", :force => true do |t|
    t.string   "structure_type"
    t.string   "name"
    t.text     "info"
    t.text     "registration_info"
    t.boolean  "gives_professional_courses"
    t.string   "website"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.string   "email_address"
    t.boolean  "accepts_holiday_vouchers",                     :default => false
    t.boolean  "accepts_ancv_sports_coupon",                   :default => false
    t.boolean  "accepts_leisure_tickets",                      :default => false
    t.boolean  "accepts_afdas_funding",                        :default => false
    t.boolean  "accepts_dif_funding",                          :default => false
    t.boolean  "accepts_cif_funding",                          :default => false
    t.boolean  "has_registration_form"
    t.boolean  "needs_photo_id_for_registration"
    t.boolean  "needs_id_copy_for_registration"
    t.boolean  "needs_medical_certificate_for_registration"
    t.boolean  "needs_insurance_attestation_for_registration"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.string   "slug"
    t.string   "address"
    t.string   "zip_code"
    t.string   "city_name"
    t.text     "description"
  end

  add_index "structures", ["slug"], :name => "index_structures_on_slug", :unique => true

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.text     "info"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "slug"
    t.string   "ancestry"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "subjects", ["slug"], :name => "index_subjects_on_slug", :unique => true

end
