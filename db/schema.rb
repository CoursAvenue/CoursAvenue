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

ActiveRecord::Schema.define(:version => 20121207200541) do

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

  create_table "course_groups", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "structure_id"
    t.integer  "discipline_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

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
    t.integer  "course_group_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
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
    t.decimal  "individual_course_price"
    t.decimal  "annual_price"
    t.decimal  "semester_price"
    t.decimal  "trimester_price"
    t.decimal  "month_price"
    t.decimal  "five_lessons_price"
    t.decimal  "five_lessons_validity"
    t.decimal  "ten_lessons_price"
    t.decimal  "ten_lessons_validity"
    t.decimal  "twenty_lessons_price"
    t.decimal  "twenty_lessons_validity"
    t.decimal  "thirty_lessons_price"
    t.decimal  "thirty_lessons_validity"
    t.decimal  "fourty_lessons_price"
    t.decimal  "fourty_lessons_validity"
    t.decimal  "fifty_lessons_price"
    t.decimal  "fifty_lessons_validity"
    t.decimal  "book_tickets_a_nb"
    t.decimal  "book_tickets_a_price"
    t.decimal  "book_tickets_a_validity"
    t.decimal  "book_tickets_b_nb"
    t.decimal  "book_tickets_b_price"
    t.decimal  "book_tickets_b_validity"
    t.decimal  "book_tickets_c_nb"
    t.decimal  "book_tickets_c_price"
    t.decimal  "book_tickets_c_validity"
    t.decimal  "two_lesson_per_week_package_price"
    t.decimal  "unlimited_access_price"
    t.decimal  "unlimited_access_validity"
    t.decimal  "student_price"
    t.decimal  "young_and_senior_price"
    t.decimal  "job_seeker_price"
    t.decimal  "low_income_price"
    t.decimal  "large_family_price"
    t.decimal  "couple_price"
    t.decimal  "annual_registration_adult_fee"
    t.decimal  "annual_registration_child_fee"
    t.integer  "price_1"
    t.string   "price_1_libelle"
    t.integer  "price_2"
    t.string   "price_2_libelle"
    t.integer  "approximate_price_per_course"
    t.text     "excluded_lesson_from_unlimited_access_card"
    t.text     "price_info_1"
    t.text     "price_info_2"
    t.boolean  "has_exceptional_offer"
    t.text     "details"
    t.text     "promotion"
    t.boolean  "is_free",                                    :default => false
    t.decimal  "degressive_price_from_two_lesson"
    t.boolean  "has_other_preferential_price"
    t.decimal  "trial_lesson_price"
    t.integer  "course_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "prices", ["approximate_price_per_course"], :name => "index_prices_on_approximate_price_per_course"

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
    t.string   "name_2"
    t.text     "info"
    t.text     "registration_info"
    t.text     "street"
    t.string   "zip_code"
    t.string   "adress_info"
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

end
