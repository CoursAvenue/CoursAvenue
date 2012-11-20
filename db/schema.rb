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

ActiveRecord::Schema.define(:version => 20121118170643) do

  create_table "audiences", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "audiences_courses", :id => false, :force => true do |t|
    t.integer "audience_id"
    t.integer "course_id"
  end

  add_index "audiences_courses", ["audience_id", "course_id"], :name => "index_audiences_courses_on_audience_id_and_course_id"

  create_table "courses", :force => true do |t|
    t.string   "type"
    t.text     "lesson_info_1"
    t.text     "lesson_info_2"
    t.integer  "max_age_for_kid"
    t.integer  "min_age_for_kid"
    t.boolean  "is_individual"
    t.integer  "structure_id"
    t.integer  "discipline_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "courses_levels", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "level_id"
  end

  add_index "courses_levels", ["level_id", "course_id"], :name => "index_courses_levels_on_level_id_and_course_id"

  create_table "disciplines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "ancestry"
  end

  add_index "disciplines", ["ancestry"], :name => "index_disciplines_on_ancestry"

  create_table "levels", :force => true do |t|
    t.string   "name"
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
    t.string   "week_day"
    t.time     "start_time"
    t.time     "end_time"
    t.time     "duration"
    t.boolean  "class_during_holidays"
    t.integer  "course_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "prices", :force => true do |t|
    t.integer  "individual_course_price"
    t.integer  "annual_price"
    t.integer  "semester_price"
    t.integer  "trimester_price"
    t.integer  "month_price"
    t.integer  "week_price"
    t.integer  "five_lessons_price"
    t.integer  "five_lessons_validity"
    t.integer  "ten_lessons_price"
    t.integer  "ten_lessons_validity"
    t.integer  "twenty_lessons_price"
    t.integer  "twenty_lessons_validity"
    t.integer  "thirty_lessons_price"
    t.integer  "thirty_lessons_validity"
    t.integer  "fourty_lessons_price"
    t.integer  "fourty_lessons_validity"
    t.integer  "fifty_lessons_price"
    t.integer  "fifty_lessons_validity"
    t.integer  "one_lesson_per_week_package_price"
    t.integer  "one_lesson_per_week_package_validity"
    t.integer  "two_lesson_per_week_package_price"
    t.integer  "two_lesson_per_week_package_validity"
    t.integer  "unlimited_access_price"
    t.integer  "unlimited_access_validity"
    t.text     "excluded_lesson_from_unlimited_access_card"
    t.text     "price_info_1"
    t.text     "price_info_2"
    t.text     "exceptional_offer"
    t.text     "details_1"
    t.text     "details_2"
    t.boolean  "is_free",                                    :default => false
    t.integer  "course_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  create_table "renting_rooms", :force => true do |t|
    t.string   "name"
    t.integer  "surface"
    t.text     "info"
    t.integer  "regular_renting_price"
    t.integer  "minimum_price"
    t.integer  "maximum_price"
    t.text     "price_info"
    t.text     "contact"
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
    t.text     "street"
    t.string   "zip_code"
    t.string   "adress_info"
    t.integer  "annual_price_child"
    t.integer  "annual_price_adult"
    t.boolean  "annual_membership_mandatory"
    t.string   "closed_days"
    t.boolean  "has_handicap_access"
    t.boolean  "is_professional"
    t.integer  "nb_room"
    t.integer  "location_room_number"
    t.string   "website"
    t.string   "newsletter_address"
    t.boolean  "online_reservation"
    t.boolean  "onlne_reservation_mandatory"
    t.boolean  "has_trial_lesson"
    t.text     "trial_lesson_info"
    t.string   "trial_lesson_price"
    t.text     "trial_lesson_info_2"
    t.text     "registration_info"
    t.boolean  "canceleable_without_fee"
    t.integer  "nb_days_before_cancelation"
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
    t.boolean  "has_multiple_place"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

end
