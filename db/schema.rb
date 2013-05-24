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

ActiveRecord::Schema.define(:version => 20130524103343) do

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

  create_table "admins", :force => true do |t|
    t.string   "email",                                  :default => "",    :null => false
    t.string   "encrypted_password",                     :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.boolean  "super_admin",                            :default => false, :null => false
    t.string   "invitation_token",         :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "structure_id"
    t.string   "civility"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.boolean  "active",                                 :default => false
    t.string   "role"
    t.string   "management_software_used"
    t.boolean  "is_teacher"
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "admins", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admins", ["invitation_token"], :name => "index_admin_users_on_invitation_token"
  add_index "admins", ["invited_by_id"], :name => "index_admin_users_on_invited_by_id"
  add_index "admins", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

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
    t.decimal  "amount"
    t.decimal  "validity"
    t.integer  "course_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.decimal  "promo_amount"
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
    t.string   "iso_code"
    t.string   "zip_code"
    t.string   "region_name"
    t.string   "region_code"
    t.string   "department_name"
    t.string   "department_code"
    t.string   "commune_name"
    t.string   "commune_code"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "acuracy"
  end

  add_index "cities", ["name"], :name => "index_cities_on_name"
  add_index "cities", ["slug"], :name => "index_cities_on_slug", :unique => true
  add_index "cities", ["zip_code"], :name => "index_cities_on_zip_code"

  create_table "click_loggers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.string   "author_name"
    t.string   "email"
    t.integer  "rating"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "title"
    t.integer  "user_id"
  end

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
    t.integer  "nb_participants"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "room_id"
    t.boolean  "active",                      :default => false
    t.time     "deleted_at"
    t.decimal  "rating"
    t.text     "subjects_string"
    t.text     "parent_subjects_string"
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

  create_table "courses_users", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  add_index "courses_users", ["course_id", "user_id"], :name => "index_courses_users_on_course_id_and_user_id"

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
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "structure_id"
  end

  create_table "participants", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "reservation_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
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
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.boolean  "has_cloackroom",           :default => false
    t.boolean  "has_internet",             :default => false
    t.boolean  "has_air_conditioning",     :default => false
    t.boolean  "has_swimming_pool",        :default => false
    t.boolean  "has_free_parking",         :default => false
    t.boolean  "has_jacuzzi",              :default => false
    t.boolean  "has_sauna",                :default => false
    t.boolean  "has_daylight",             :default => false
    t.string   "slug"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "thumb_image_file_name"
    t.string   "thumb_image_content_type"
    t.integer  "thumb_image_file_size"
    t.datetime "thumb_image_updated_at"
    t.time     "deleted_at"
    t.text     "description"
    t.text     "subjects_string"
    t.text     "parent_subjects_string"
  end

  add_index "places", ["slug"], :name => "index_places_on_slug", :unique => true
  add_index "places", ["zip_code"], :name => "index_places_on_zip_code"

  create_table "places_users", :id => false, :force => true do |t|
    t.integer "place_id"
    t.integer "user_id"
  end

  add_index "places_users", ["place_id", "user_id"], :name => "index_places_users_on_place_id_and_user_id"

  create_table "plannings", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "week_day"
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "class_during_holidays"
    t.decimal  "promotion"
    t.integer  "nb_place_available"
    t.text     "info"
    t.integer  "max_age_for_kid"
    t.integer  "min_age_for_kid"
    t.integer  "course_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "room_id"
    t.integer  "teacher_id"
    t.integer  "total_nb_place"
    t.integer  "duration"
  end

  add_index "plannings", ["week_day"], :name => "index_plannings_on_week_day"

  create_table "plannings_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "planning_id"
  end

  add_index "plannings_users", ["planning_id", "user_id"], :name => "index_plannings_users_on_planning_id_and_user_id"

  create_table "prices", :force => true do |t|
    t.string   "libelle"
    t.decimal  "amount"
    t.integer  "course_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "nb_courses"
    t.decimal  "promo_amount"
  end

  create_table "pricing_plans", :force => true do |t|
    t.string   "name"
    t.decimal  "price"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "registration_fees", :force => true do |t|
    t.decimal  "amount"
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
    t.string   "contact_email"
    t.string   "contact_phone"
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
    t.string   "contact_name"
    t.string   "address"
  end

  create_table "reservation_loggers", :force => true do |t|
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reservations", :force => true do |t|
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "user_id"
    t.integer  "reservable_id"
    t.string   "reservable_type"
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.integer  "surface"
    t.integer  "place_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.string   "contact_email"
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
    t.string   "street"
    t.string   "zip_code"
    t.text     "description"
    t.string   "siret"
    t.string   "tva_intracom_number"
    t.string   "structure_status"
    t.string   "billing_contact_first_name"
    t.string   "billing_contact_last_name"
    t.string   "billing_contact_phone_number"
    t.string   "billing_contact_email"
    t.string   "bank_name"
    t.string   "bank_iban"
    t.string   "bank_bic"
    t.integer  "city_id"
    t.boolean  "active",                                       :default => false
    t.integer  "pricing_plan_id"
    t.boolean  "has_validated_conditions",                     :default => false
    t.integer  "validated_by"
    t.string   "cancel_condition"
    t.string   "modification_condition"
    t.time     "deleted_at"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "subjects_string"
    t.text     "parent_subjects_string"
    t.decimal  "rating"
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
    t.string   "short_name"
  end

  add_index "subjects", ["slug"], :name => "index_subjects_on_slug", :unique => true

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.integer  "admin_id"
    t.integer  "structure_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "description"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "image"
    t.string   "location"
    t.string   "slug"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

end
