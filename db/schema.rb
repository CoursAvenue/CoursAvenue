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

ActiveRecord::Schema.define(:version => 20130126102349) do

  create_table "audiences", :force => true do |t|
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "audiences", ["name"], :name => "index_audiences_on_name"

  create_table "audiences_course_groups", :id => false, :force => true do |t|
    t.integer "audience_id"
    t.integer "course_group_id"
  end

  add_index "audiences_course_groups", ["audience_id", "course_group_id"], :name => "audience_course_group_index"

  create_table "book_tickets", :force => true do |t|
    t.integer  "number"
    t.decimal  "price"
    t.string   "validity"
    t.integer  "course_group_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "course_groups", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "has_online_payment", :default => false
    t.boolean  "has_promotion",      :default => false
    t.integer  "structure_id"
    t.integer  "discipline_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "slug"
  end

  add_index "course_groups", ["slug"], :name => "index_course_groups_on_slug", :unique => true
  add_index "course_groups", ["type"], :name => "index_course_groups_on_type"

  create_table "course_groups_levels", :id => false, :force => true do |t|
    t.integer "course_group_id"
    t.integer "level_id"
  end

  add_index "course_groups_levels", ["level_id", "course_group_id"], :name => "index_course_groups_levels_on_level_id_and_course_group_id"

  create_table "courses", :force => true do |t|
    t.text     "course_info_1"
    t.text     "course_info_2"
    t.text     "registration_date"
    t.text     "teacher_name"
    t.integer  "max_age_for_kid"
    t.integer  "min_age_for_kid"
    t.boolean  "is_individual"
    t.boolean  "annual_membership_mandatory"
    t.boolean  "is_for_handicaped"
    t.boolean  "has_online_payment",          :default => false
    t.text     "formule_1"
    t.text     "formule_2"
    t.text     "formule_3"
    t.text     "formule_4"
    t.text     "conditions"
    t.integer  "nb_place_available"
    t.text     "partner_rib_info"
    t.boolean  "audition_mandatory"
    t.text     "refund_condition"
    t.decimal  "promotion"
    t.boolean  "cant_be_joined_during_year"
    t.text     "trial_lesson_info"
    t.text     "price_details"
    t.text     "price_info_1"
    t.text     "price_info_2"
    t.integer  "course_group_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "disciplines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "ancestry"
  end

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

  create_table "plannings", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "recurrence"
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
    t.integer  "course_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "plannings", ["week_day"], :name => "index_plannings_on_week_day"

  create_table "prices", :force => true do |t|
    t.string   "libelle"
    t.decimal  "amount"
    t.integer  "course_group_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
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
    t.string   "city"
    t.string   "name"
    t.string   "name_2"
    t.text     "info"
    t.text     "registration_info"
    t.text     "street"
    t.string   "zip_code"
    t.text     "adress_info"
    t.string   "closed_days"
    t.boolean  "has_handicap_access"
    t.boolean  "is_professional"
    t.integer  "nb_room"
    t.integer  "nb_days_before_cancelation"
    t.string   "website"
    t.string   "newsletter_address"
    t.boolean  "has_online_reservation"
    t.string   "online_reservation_website"
    t.boolean  "onlne_reservation_mandatory"
    t.boolean  "has_online_membership"
    t.string   "online_membership_website"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.string   "email_address"
    t.string   "email_address_2"
    t.string   "contact_name"
    t.boolean  "accepts_holiday_vouchers"
    t.boolean  "accepts_ancv_sports_coupon"
    t.boolean  "accepts_leisure_tickets"
    t.boolean  "accepts_afdas_funding"
    t.boolean  "accepts_dif_funding"
    t.boolean  "accepts_cif_funding"
    t.boolean  "has_multiple_place"
    t.boolean  "has_annual_course_only"
    t.boolean  "has_registration_form"
    t.boolean  "needs_photo_id_for_registration"
    t.boolean  "needs_id_copy_for_registration"
    t.boolean  "needs_payment_on_place_for_registration"
    t.boolean  "needs_medical_certificate_for_registration"
    t.boolean  "needs_insurance_attestation_for_registration"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
  end

  add_index "structures", ["city"], :name => "index_structures_on_city"

end
