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

ActiveRecord::Schema.define(version: 20141007095942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"

  create_table "admins", force: true do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "super_admin",                       default: false, null: false
    t.string   "invitation_token",       limit: 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "structure_id"
    t.string   "civility"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.time     "deleted_at"
    t.boolean  "email_opt_in",                      default: true
    t.hstore   "email_opt_in_status"
    t.string   "delivery_email_status"
  end

  add_index "admins", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admins", ["invitation_token"], name: "index_admin_users_on_invitation_token", using: :btree
  add_index "admins", ["invited_by_id"], name: "index_admin_users_on_invited_by_id", using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "blog_articles", force: true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.text     "content"
    t.boolean  "published"
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cover_image_file_name"
    t.string   "cover_image_content_type"
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
  end

  create_table "blog_articles_subjects", force: true do |t|
    t.integer "article_id"
    t.integer "subject_id"
  end

  add_index "blog_articles_subjects", ["article_id", "subject_id"], name: "index_blog_articles_subjects_on_article_id_and_subject_id", using: :btree

  create_table "cities", force: true do |t|
    t.string   "name"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
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
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "title"
    t.text     "subtitle"
    t.text     "description"
  end

  add_index "cities", ["name"], name: "index_cities_on_name", using: :btree
  add_index "cities", ["slug"], name: "index_cities_on_slug", unique: true, using: :btree
  add_index "cities", ["zip_code"], name: "index_cities_on_zip_code", using: :btree

  create_table "city_subject_infos", force: true do |t|
    t.integer  "city_id"
    t.integer  "subject_id"
    t.text     "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "where_to_practice"
    t.text     "where_to_suit_up"
    t.text     "average_price"
    t.text     "tips"
  end

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "click_logs", force: true do |t|
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "structure_id"
    t.text     "info"
  end

  add_index "click_logs", ["structure_id"], name: "index_click_logs_on_structure_id", using: :btree

  create_table "comment_notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "structure_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notification_for"
    t.text     "text"
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
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "title"
    t.integer  "user_id"
    t.time     "deleted_at"
    t.string   "course_name"
    t.string   "status"
    t.string   "deletion_reason"
    t.string   "type"
    t.integer  "associated_message_id"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree

  create_table "comments_subjects", id: false, force: true do |t|
    t.integer "comment_id"
    t.integer "subject_id"
  end

  add_index "comments_subjects", ["comment_id", "subject_id"], name: "index_comments_subjects_on_comment_id_and_subject_id", using: :btree

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

  create_table "courses", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "frequency"
    t.text     "description"
    t.boolean  "is_promoted",                 default: false
    t.text     "info"
    t.boolean  "is_individual"
    t.boolean  "cant_be_joined_during_year"
    t.integer  "structure_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "slug"
    t.integer  "place_id"
    t.integer  "nb_participants_max"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "room_id"
    t.boolean  "active",                      default: false
    t.time     "deleted_at"
    t.decimal  "rating"
    t.text     "subjects_string"
    t.text     "parent_subjects_string"
    t.boolean  "no_class_during_holidays"
    t.boolean  "teaches_at_home"
    t.string   "event_type"
    t.string   "event_type_description"
    t.float    "price"
    t.integer  "nb_participants_min"
    t.text     "ca_follow_up"
    t.float    "common_price"
    t.boolean  "ok_nico",                     default: false
    t.integer  "price_group_id"
    t.string   "audience_ids"
    t.string   "level_ids"
    t.integer  "min_age_for_kid"
    t.integer  "max_age_for_kid"
    t.boolean  "on_appointment",              default: false
    t.boolean  "available_in_discovery_pass"
  end

  add_index "courses", ["active"], name: "index_courses_on_active", using: :btree
  add_index "courses", ["place_id"], name: "index_courses_on_place_id", using: :btree
  add_index "courses", ["slug"], name: "index_courses_on_slug", unique: true, using: :btree
  add_index "courses", ["structure_id"], name: "index_courses_on_structure_id", using: :btree
  add_index "courses", ["type"], name: "index_courses_on_type", using: :btree

  create_table "courses_subjects", id: false, force: true do |t|
    t.integer "course_id"
    t.integer "subject_id"
  end

  add_index "courses_subjects", ["course_id", "subject_id"], name: "index_courses_subjects_on_course_id_and_subject_id", using: :btree

  create_table "courses_users", id: false, force: true do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  add_index "courses_users", ["course_id", "user_id"], name: "index_courses_users_on_course_id_and_user_id", using: :btree

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

  create_table "discovery_passes", force: true do |t|
    t.integer  "user_id"
    t.date     "expires_at"
    t.date     "renewed_at"
    t.datetime "last_renewal_failed_at"
    t.datetime "canceled_at"
    t.string   "credit_card_number"
    t.string   "be2bill_alias"
    t.string   "client_ip"
    t.string   "card_validity_date"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "meta_data"
  end

  create_table "emailing_section_bridges", force: true do |t|
    t.integer "emailing_section_id"
    t.integer "structure_id"
    t.integer "media_id"
    t.boolean "is_logo"
  end

  add_index "emailing_section_bridges", ["emailing_section_id", "structure_id"], name: "comments_subjects_index", using: :btree

  create_table "emailing_sections", force: true do |t|
    t.string   "title"
    t.integer  "emailing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
    t.string   "link_name"
  end

  create_table "emailings", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "header_image_file_name"
    t.string   "header_image_content_type"
    t.integer  "header_image_file_size"
    t.datetime "header_image_updated_at"
    t.string   "section_metadata_one"
    t.string   "section_metadata_two"
    t.string   "section_metadata_three"
  end

  create_table "emails", force: true do |t|
    t.string   "email"
    t.string   "email_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "followings", force: true do |t|
    t.integer  "structure_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followings", ["user_id", "structure_id"], name: "index_followings_on_user_id_and_structure_id", using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "invited_users", force: true do |t|
    t.string   "email",                          null: false
    t.integer  "referrer_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "email_status"
    t.boolean  "registered",     default: false
    t.string   "type"
    t.text     "email_text"
    t.string   "referrer_type"
    t.string   "invitation_for"
    t.hstore   "meta_data"
  end

  create_table "keywords", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lived_places", force: true do |t|
    t.integer "city_id"
    t.integer "user_id"
    t.string  "zip_code"
    t.float   "radius"
  end

  add_index "lived_places", ["city_id", "user_id"], name: "index_lived_places_on_city_id_and_user_id", using: :btree

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

  create_table "mailboxer_conversation_opt_outs", force: true do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  create_table "mailboxer_conversations", force: true do |t|
    t.string   "subject",                  default: ""
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "mailboxer_label_id"
    t.boolean  "treated_by_phone",         default: false
    t.datetime "treated_at"
    t.string   "flagged"
    t.datetime "flagged_at"
    t.string   "mailboxer_extra_info_ids"
    t.string   "mailboxer_course_ids"
    t.integer  "participation_request_id"
  end

  create_table "mailboxer_notifications", force: true do |t|
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

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree

  create_table "mailboxer_receipts", force: true do |t|
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

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree

  create_table "medias", force: true do |t|
    t.text     "url"
    t.text     "url_html"
    t.text     "caption"
    t.integer  "mediable_id"
    t.string   "mediable_type"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.time     "deleted_at"
    t.string   "format"
    t.string   "provider_id"
    t.string   "provider_name"
    t.text     "thumbnail_url"
    t.string   "type"
    t.string   "filepicker_url"
    t.boolean  "cover",                  default: false
    t.boolean  "star"
    t.string   "vertical_page_caption"
    t.string   "old_image_file_name"
    t.string   "old_image_content_type"
    t.integer  "old_image_file_size"
    t.datetime "old_image_updated_at"
    t.boolean  "image_processing"
    t.string   "image"
    t.string   "remote_image_url"
  end

  add_index "medias", ["format"], name: "index_medias_on_format", using: :btree
  add_index "medias", ["mediable_id"], name: "index_medias_on_mediable_id", using: :btree
  add_index "medias", ["mediable_type"], name: "index_medias_on_mediable_type", using: :btree

  create_table "medias_subjects", id: false, force: true do |t|
    t.integer "subject_id"
    t.integer "media_id"
  end

  create_table "orders", force: true do |t|
    t.string   "order_id"
    t.string   "subscription_type"
    t.decimal  "amount"
    t.integer  "structure_id"
    t.integer  "subscription_plan_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "promotion_code_id"
    t.string   "type"
    t.integer  "user_id"
  end

  create_table "participation_requests", force: true do |t|
    t.integer  "mailboxer_conversation_id"
    t.integer  "planning_id"
    t.integer  "user_id"
    t.integer  "structure_id"
    t.string   "state"
    t.date     "date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_modified_by"
  end

  create_table "participations", force: true do |t|
    t.integer  "user_id"
    t.integer  "planning_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "deleted_at"
    t.boolean  "waiting_list",      default: false
    t.datetime "canceled_at"
    t.string   "participation_for"
    t.integer  "nb_adults",         default: 1
    t.integer  "nb_kids",           default: 0
  end

  add_index "participations", ["planning_id", "user_id"], name: "index_participations_on_planning_id_and_user_id", using: :btree

  create_table "participations_users", id: false, force: true do |t|
    t.integer "participation_id"
    t.integer "user_id"
  end

  add_index "participations_users", ["participation_id", "user_id"], name: "index_participations_users_on_participation_id_and_user_id", using: :btree

  create_table "passions", force: true do |t|
    t.integer  "user_id"
    t.string   "passion_frequency_ids"
    t.boolean  "practiced",               default: true
    t.string   "passion_expectation_ids"
    t.string   "passion_reason_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "info"
    t.string   "level_ids"
    t.string   "passion_for_ids"
    t.string   "passion_time_slot_ids"
  end

  create_table "passions_subjects", id: false, force: true do |t|
    t.integer "passion_id"
    t.integer "subject_id"
  end

  add_index "passions_subjects", ["passion_id", "subject_id"], name: "index_passions_subjects_on_passion_id_and_subject_id", using: :btree

  create_table "payment_notifications", force: true do |t|
    t.text     "params"
    t.integer  "structure_id"
    t.string   "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "user_id"
    t.string   "product_type"
  end

  create_table "phone_numbers", force: true do |t|
    t.string   "number"
    t.string   "phone_type"
    t.integer  "callable_id"
    t.string   "callable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phone_numbers", ["callable_id"], name: "index_phone_numbers_on_callable_id", using: :btree
  add_index "phone_numbers", ["callable_type"], name: "index_phone_numbers_on_callable_type", using: :btree

  create_table "places", force: true do |t|
    t.integer  "location_id"
    t.integer  "structure_id"
    t.text     "info"
    t.time     "deleted_at"
    t.text     "private_info"
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "street"
    t.string   "zip_code"
    t.integer  "city_id"
    t.boolean  "gmaps"
    t.string   "type"
    t.integer  "radius"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_geocode_try"
  end

  add_index "places", ["location_id", "structure_id"], name: "index_places_on_location_id_and_structure_id", using: :btree

  create_table "places_users", id: false, force: true do |t|
    t.integer "place_id"
    t.integer "user_id"
  end

  add_index "places_users", ["place_id", "user_id"], name: "index_places_users_on_place_id_and_user_id", using: :btree

  create_table "plannings", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "week_day"
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "class_during_holidays"
    t.decimal  "promotion"
    t.text     "info"
    t.integer  "max_age_for_kid"
    t.integer  "min_age_for_kid"
    t.integer  "course_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "room_id"
    t.integer  "teacher_id"
    t.integer  "nb_participants_max"
    t.integer  "duration"
    t.string   "audience_ids"
    t.string   "level_ids"
    t.time     "deleted_at"
    t.integer  "place_id"
    t.integer  "structure_id"
    t.boolean  "visible",                     default: true
    t.boolean  "is_in_foreign_country",       default: false
    t.boolean  "available_in_discovery_pass"
  end

  add_index "plannings", ["audience_ids"], name: "index_plannings_on_audience_ids", using: :btree
  add_index "plannings", ["level_ids"], name: "index_plannings_on_level_ids", using: :btree
  add_index "plannings", ["week_day"], name: "index_plannings_on_week_day", using: :btree

  create_table "plannings_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "planning_id"
  end

  add_index "plannings_users", ["planning_id", "user_id"], name: "index_plannings_users_on_planning_id_and_user_id", using: :btree

  create_table "portraits", force: true do |t|
    t.string   "top_line_about"
    t.string   "thumb_title"
    t.string   "thumb_subtitle"
    t.text     "title"
    t.text     "quote_name"
    t.text     "quote"
    t.text     "top_line"
    t.text     "content"
    t.text     "bottom_line"
    t.string   "slug"
    t.boolean  "visible"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_articles", force: true do |t|
    t.string   "title"
    t.text     "url"
    t.text     "description"
    t.date     "published_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "price_groups", force: true do |t|
    t.string   "name"
    t.string   "course_type"
    t.text     "details"
    t.boolean  "premium_visible"
    t.integer  "structure_id"
    t.time     "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prices", force: true do |t|
    t.string   "libelle"
    t.decimal  "amount"
    t.integer  "course_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "nb_courses"
    t.decimal  "promo_amount"
    t.time     "deleted_at"
    t.text     "info"
    t.string   "type"
    t.integer  "number"
    t.decimal  "promo_percentage"
    t.integer  "duration"
    t.integer  "price_group_id"
    t.string   "promo_amount_type"
  end

  add_index "prices", ["type"], name: "index_prices_on_type", using: :btree

  create_table "promotion_codes", force: true do |t|
    t.string   "name"
    t.string   "code_id"
    t.integer  "promo_amount"
    t.string   "plan_type"
    t.date     "expires_at"
    t.integer  "usage_nb",     default: 0
    t.integer  "max_usage_nb"
    t.datetime "canceled_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "apply_until"
  end

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

  create_table "search_term_logs", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sponsorships", force: true do |t|
    t.integer  "user_id"
    t.integer  "sponsored_user_id"
    t.boolean  "registered",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "promo_code"
  end

  create_table "statistics", force: true do |t|
    t.integer  "structure_id"
    t.string   "action_type"
    t.string   "user_fingerprint"
    t.text     "infos"
    t.time     "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
  end

  create_table "sticker_demands", force: true do |t|
    t.integer  "round_number"
    t.integer  "square_number"
    t.integer  "structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "address"
    t.datetime "sent_at"
  end

  create_table "structures", force: true do |t|
    t.string   "structure_type"
    t.string   "name"
    t.text     "info"
    t.text     "registration_info"
    t.string   "website"
    t.string   "contact_phone"
    t.string   "contact_mobile_phone"
    t.string   "contact_email"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "slug"
    t.string   "street"
    t.string   "zip_code"
    t.text     "description"
    t.integer  "city_id"
    t.boolean  "active",                         default: false
    t.boolean  "has_validated_conditions",       default: false
    t.integer  "validated_by"
    t.time     "deleted_at"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.text     "subjects_string"
    t.text     "parent_subjects_string"
    t.decimal  "rating"
    t.integer  "comments_count",                 default: 0
    t.text     "facebook_url"
    t.boolean  "no_facebook"
    t.boolean  "no_website"
    t.string   "old_logo_file_name"
    t.string   "old_logo_content_type"
    t.integer  "old_logo_file_size"
    t.datetime "old_logo_updated_at"
    t.integer  "crop_x",                         default: 0
    t.integer  "crop_y",                         default: 0
    t.integer  "crop_width",                     default: 500
    t.boolean  "has_only_one_place"
    t.string   "email_status"
    t.datetime "last_email_sent_at"
    t.string   "last_email_sent_status"
    t.string   "funding_type_ids"
    t.string   "widget_status"
    t.string   "sticker_status"
    t.boolean  "teaches_at_home",                default: false
    t.text     "widget_url"
    t.integer  "teaches_at_home_radius"
    t.hstore   "meta_data"
    t.integer  "highlighted_comment_id"
    t.string   "pricing_plan",                   default: "free"
    t.datetime "last_geocode_try"
    t.string   "old_sleeping_logo_file_name"
    t.string   "old_sleeping_logo_content_type"
    t.integer  "old_sleeping_logo_file_size"
    t.datetime "old_sleeping_logo_updated_at"
    t.text     "sleeping_attributes"
    t.boolean  "logo_processing"
    t.string   "delivery_email_status"
    t.string   "logo"
    t.string   "sleeping_logo"
    t.string   "remote_logo_url"
    t.string   "discovery_pass_policy"
  end

  add_index "structures", ["slug"], name: "index_structures_on_slug", unique: true, using: :btree

  create_table "structures_subjects", id: false, force: true do |t|
    t.integer "structure_id"
    t.integer "subject_id"
  end

  add_index "structures_subjects", ["structure_id", "subject_id"], name: "index_structures_subjects_on_structure_id_and_subject_id", using: :btree

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
    t.text     "title"
    t.text     "description"
    t.text     "subtitle"
    t.text     "good_to_know"
    t.text     "needed_meterial"
    t.text     "tips"
  end

  add_index "subjects", ["ancestry_depth"], name: "index_subjects_on_ancestry_depth", using: :btree
  add_index "subjects", ["position"], name: "index_subjects_on_position", using: :btree
  add_index "subjects", ["slug"], name: "index_subjects_on_slug", unique: true, using: :btree

  create_table "subjects_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "subject_id"
  end

  add_index "subjects_users", ["user_id", "subject_id"], name: "index_subjects_users_on_user_id_and_subject_id", using: :btree

  create_table "subscription_plan_exports", force: true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_plans", force: true do |t|
    t.string   "plan_type"
    t.string   "credit_card_number"
    t.string   "be2bill_alias"
    t.string   "client_ip"
    t.boolean  "recurrent",                      default: true
    t.date     "expires_at"
    t.date     "renewed_at"
    t.datetime "canceled_at"
    t.hstore   "meta_data"
    t.integer  "structure_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "card_validity_date"
    t.integer  "promotion_code_id"
    t.datetime "last_renewal_failed_at"
    t.string   "paypal_token"
    t.string   "paypal_payer_id"
    t.hstore   "bo_meta_data"
    t.string   "paypal_recurring_profile_token"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

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

  create_table "unfinished_resources", force: true do |t|
    t.hstore   "fields"
    t.integer  "visitor_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
  end

  add_index "unfinished_resources", ["visitor_id"], name: "index_unfinished_resources_on_visitor_id", using: :btree

  create_table "user_profile_imports", force: true do |t|
    t.binary   "data",         null: false
    t.string   "filename"
    t.string   "mime_type"
    t.integer  "structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_profiles", force: true do |t|
    t.integer "structure_id"
    t.integer "user_id"
    t.string  "email"
    t.string  "first_name"
    t.string  "last_name"
    t.date    "birthdate"
    t.text    "notes"
    t.string  "phone"
    t.string  "mobile_phone"
    t.text    "address"
  end

  add_index "user_profiles", ["structure_id", "user_id"], name: "index_user_profiles_on_structure_id_and_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                   default: "",    null: false
    t.string   "encrypted_password",      default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
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
    t.string   "gender"
    t.date     "birthdate"
    t.boolean  "email_opt_in",            default: true
    t.string   "first_name"
    t.string   "last_name"
    t.string   "zip_code"
    t.string   "phone_number"
    t.integer  "city_id"
    t.text     "description"
    t.boolean  "email_promo_opt_in",      default: true
    t.boolean  "email_newsletter_opt_in", default: true
    t.boolean  "email_passions_opt_in",   default: true
    t.boolean  "sms_opt_in",              default: true
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.hstore   "meta_data"
    t.string   "email_status"
    t.string   "last_email_sent_at"
    t.string   "last_email_sent_status"
    t.boolean  "super_user",              default: false
    t.integer  "passion_city_id"
    t.string   "passion_zip_code"
    t.string   "delivery_email_status"
    t.integer  "sponsorship_id"
    t.string   "sponsorship_slug"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  create_table "vertical_pages", force: true do |t|
    t.string   "name"
    t.text     "caption"
    t.text     "title"
    t.text     "content"
    t.text     "keywords"
    t.string   "slug"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "checked",            default: false
    t.text     "comments"
    t.text     "sidebar_title"
  end

  create_table "visitors", force: true do |t|
    t.string   "fingerprint"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "address_name"
    t.hstore   "subject_id"
  end

  add_index "visitors", ["fingerprint"], name: "index_visitors_on_fingerprint", using: :btree

  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", name: "mb_opt_outs_on_conversations_id", column: "conversation_id"

  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", name: "notifications_on_conversation_id", column: "conversation_id"

  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", name: "receipts_on_notification_id", column: "notification_id"

end
