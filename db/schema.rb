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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131107155352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree

  create_table "admins", force: true do |t|
    t.string   "email",                               default: "",    null: false
    t.string   "encrypted_password",                  default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "super_admin",                         default: false, null: false
    t.string   "invitation_token",         limit: 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "structure_id"
    t.string   "civility"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.string   "management_software_used"
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.time     "deleted_at"
    t.boolean  "email_opt_in",                        default: true
  end

  add_index "admins", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admins", ["invitation_token"], name: "index_admin_users_on_invitation_token", using: :btree
  add_index "admins", ["invited_by_id"], name: "index_admin_users_on_invited_by_id", using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "cities", force: true do |t|
    t.string   "name"
    t.string   "no_result_image_file_name"
    t.string   "no_result_image_content_type"
    t.integer  "no_result_image_file_size"
    t.datetime "no_result_image_updated_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
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

  add_index "cities", ["name"], name: "index_cities_on_name", using: :btree
  add_index "cities", ["slug"], name: "index_cities_on_slug", unique: true, using: :btree
  add_index "cities", ["zip_code"], name: "index_cities_on_zip_code", using: :btree

  create_table "click_loggers", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comment_notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "structure_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comment_notifications", ["status"], name: "index_comment_notifications_on_status", using: :btree
  add_index "comment_notifications", ["structure_id"], name: "index_comment_notifications_on_structure_id", using: :btree
  add_index "comment_notifications", ["user_id"], name: "index_comment_notifications_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.text     "content"
    t.string   "author_name"
    t.string   "email"
    t.integer  "rating"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "title"
    t.integer  "user_id"
    t.time     "deleted_at"
    t.string   "course_name"
    t.string   "status"
    t.string   "deletion_reason"
  end

  create_table "contacts", force: true do |t|
    t.integer  "contactable_id",   null: false
    t.string   "contactable_type", null: false
    t.string   "name"
    t.string   "phone"
    t.string   "mobile_phone"
    t.string   "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.time     "deleted_at"
  end

  create_table "conversations", force: true do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "courses", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "frequency"
    t.text     "description"
    t.boolean  "is_promoted",                default: false
    t.boolean  "has_online_payment",         default: false
    t.text     "info"
    t.text     "registration_date"
    t.boolean  "is_individual"
    t.boolean  "is_for_handicaped"
    t.text     "trial_lesson_info"
    t.text     "price_details"
    t.text     "conditions"
    t.text     "partner_rib_info"
    t.boolean  "audition_mandatory"
    t.text     "refund_condition"
    t.boolean  "cant_be_joined_during_year"
    t.integer  "structure_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "slug"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "place_id"
    t.integer  "nb_participants"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "room_id"
    t.boolean  "active",                     default: false
    t.time     "deleted_at"
    t.decimal  "rating"
    t.text     "subjects_string"
    t.text     "parent_subjects_string"
    t.boolean  "no_class_during_holidays"
    t.boolean  "teaches_at_home"
  end

  add_index "courses", ["place_id"], name: "index_courses_on_place_id", using: :btree
  add_index "courses", ["slug"], name: "index_courses_on_slug", unique: true, using: :btree
  add_index "courses", ["type"], name: "index_courses_on_type", using: :btree

  create_table "courses_subjects", id: false, force: true do |t|
    t.integer "course_id"
    t.integer "subject_id"
  end

  add_index "courses_subjects", ["course_id", "subject_id"], name: "index_courses_subjects_on_course_id_and_subject_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "emails", force: true do |t|
    t.string   "email"
    t.string   "email_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "invited_teachers", force: true do |t|
    t.string   "email",                        null: false
    t.integer  "structure_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "email_status"
    t.boolean  "registered",   default: false
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "street"
    t.string   "zip_code"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_mobile_phone"
    t.string   "contact_email"
    t.integer  "structure_id"
    t.integer  "city_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.string   "slug"
    t.time     "deleted_at"
    t.boolean  "shared"
  end

  add_index "locations", ["slug"], name: "index_places_on_slug", unique: true, using: :btree
  add_index "locations", ["zip_code"], name: "index_places_on_zip_code", using: :btree

  create_table "medias", force: true do |t|
    t.text     "url"
    t.text     "url_html"
    t.string   "caption"
    t.integer  "mediable_id"
    t.string   "mediable_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.time     "deleted_at"
    t.string   "format"
  end

  add_index "medias", ["format"], name: "index_medias_on_format", using: :btree

  create_table "notifications", force: true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "notifications", ["conversation_id"], name: "index_notifications_on_conversation_id", using: :btree

  create_table "participants", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "reservation_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "places", force: true do |t|
    t.integer "location_id"
    t.integer "structure_id"
    t.text    "info"
    t.time    "deleted_at"
  end

  add_index "places", ["location_id", "structure_id"], name: "index_places_on_location_id_and_structure_id", using: :btree

  create_table "plannings", force: true do |t|
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
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "room_id"
    t.integer  "teacher_id"
    t.integer  "total_nb_place"
    t.integer  "duration"
    t.string   "audience_ids"
    t.string   "level_ids"
    t.time     "deleted_at"
    t.integer  "place_id"
  end

  add_index "plannings", ["audience_ids"], name: "index_plannings_on_audience_ids", using: :btree
  add_index "plannings", ["level_ids"], name: "index_plannings_on_level_ids", using: :btree
  add_index "plannings", ["week_day"], name: "index_plannings_on_week_day", using: :btree

  create_table "prices", force: true do |t|
    t.string   "libelle"
    t.decimal  "amount"
    t.integer  "course_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "nb_courses"
    t.decimal  "promo_amount"
    t.time     "deleted_at"
    t.text     "info"
    t.string   "type"
    t.integer  "number"
    t.decimal  "promo_percentage"
    t.integer  "duration"
  end

  add_index "prices", ["type"], name: "index_prices_on_type", using: :btree

  create_table "pricing_plans", force: true do |t|
    t.string   "name"
    t.decimal  "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "receipts", force: true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "receipts", ["notification_id"], name: "index_receipts_on_notification_id", using: :btree

  create_table "reservation_loggers", force: true do |t|
    t.integer  "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservations", force: true do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_id"
    t.integer  "reservable_id"
    t.string   "reservable_type"
  end

  create_table "structures", force: true do |t|
    t.string   "structure_type"
    t.string   "name"
    t.text     "info"
    t.text     "registration_info"
    t.boolean  "gives_professional_courses"
    t.string   "website"
    t.string   "contact_phone"
    t.string   "contact_mobile_phone"
    t.string   "contact_email"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "slug"
    t.string   "street"
    t.string   "zip_code"
    t.text     "description"
    t.integer  "city_id"
    t.boolean  "active",                     default: false
    t.integer  "pricing_plan_id"
    t.boolean  "has_validated_conditions",   default: false
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
    t.integer  "comments_count",             default: 0
    t.text     "facebook_url"
    t.boolean  "no_facebook"
    t.boolean  "no_website"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "crop_x",                     default: 0
    t.integer  "crop_y",                     default: 0
    t.integer  "crop_width",                 default: 500
    t.integer  "crop_height",                default: 500
    t.boolean  "cropping",                   default: false
    t.boolean  "has_only_one_place"
    t.string   "email_status"
    t.datetime "last_email_sent_at"
    t.string   "last_email_sent_status"
    t.string   "funding_type_ids"
    t.string   "widget_status"
    t.string   "sticker_status"
    t.boolean  "teaches_at_home",            default: false
    t.text     "widget_url"
    t.integer  "min_price_id"
    t.integer  "max_price_id"
    t.string   "audience_ids"
    t.boolean  "gives_group_courses"
    t.boolean  "gives_individual_courses"
    t.integer  "teaches_at_home_radius"
  end

  add_index "structures", ["slug"], name: "index_structures_on_slug", unique: true, using: :btree

  create_table "structures_subjects", id: false, force: true do |t|
    t.integer "structure_id"
    t.integer "subject_id"
  end

  add_index "structures_subjects", ["structure_id", "subject_id"], name: "index_structures_subjects_on_structure_id_and_subject_id", using: :btree

  create_table "structures_users", id: false, force: true do |t|
    t.integer "structure_id"
    t.integer "user_id"
  end

  add_index "structures_users", ["structure_id", "user_id"], name: "index_structures_users_on_structure_id_and_user_id", using: :btree

  create_table "students", force: true do |t|
    t.string   "city"
    t.string   "email"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "structure_id"
    t.string   "email_status"
    t.boolean  "email_opt_in", default: true
  end

  add_index "students", ["structure_id"], name: "index_students_on_structure_id", using: :btree

  create_table "subjects", force: true do |t|
    t.string   "name"
    t.text     "info"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "slug"
    t.string   "ancestry"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "short_name"
    t.integer  "position"
    t.integer  "ancestry_depth",     default: 0
  end

  add_index "subjects", ["ancestry_depth"], name: "index_subjects_on_ancestry_depth", using: :btree
  add_index "subjects", ["position"], name: "index_subjects_on_position", using: :btree
  add_index "subjects", ["slug"], name: "index_subjects_on_slug", unique: true, using: :btree

  create_table "subjects_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "subject_id"
  end

  add_index "subjects_users", ["user_id", "subject_id"], name: "index_subjects_users_on_user_id_and_subject_id", using: :btree

  create_table "teachers", force: true do |t|
    t.string   "name"
    t.integer  "admin_id"
    t.integer  "structure_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "description"
    t.time     "deleted_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "fb_avatar"
    t.string   "location"
    t.string   "slug"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "name"
    t.string   "gender"
    t.date     "birthdate"
    t.boolean  "email_opt_in",           default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  add_foreign_key "notifications", "conversations", name: "notifications_on_conversation_id"

  add_foreign_key "receipts", "notifications", name: "receipts_on_notification_id"

end
