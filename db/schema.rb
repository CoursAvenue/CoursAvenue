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

ActiveRecord::Schema.define(version: 20150922100440) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"

  create_table "admin_images", force: true do |t|
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "civility"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "email_opt_in",                      default: true
    t.hstore   "email_opt_in_status"
    t.string   "delivery_email_status"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.boolean  "sms_opt_in",                        default: true
    t.datetime "deleted_at"
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
    t.integer  "category_id"
    t.string   "page_title"
    t.text     "page_description"
    t.string   "type"
    t.string   "image"
    t.integer  "author_id"
    t.integer  "page_views",       default: 0
    t.text     "box_top"
    t.text     "box_bottom"
  end

  create_table "blog_articles_subjects", force: true do |t|
    t.integer "article_id"
    t.integer "subject_id"
  end

  add_index "blog_articles_subjects", ["article_id", "subject_id"], name: "index_blog_articles_subjects_on_article_id_and_subject_id", using: :btree

  create_table "blog_authors", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
  end

  create_table "blog_categories", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "page_title"
    t.text     "description"
    t.text     "page_description"
    t.string   "type"
    t.string   "ancestry"
    t.integer  "ancestry_depth",   default: 0
    t.string   "color"
    t.string   "subtitle"
    t.integer  "position"
    t.string   "image"
  end

  add_index "blog_categories", ["ancestry"], name: "index_blog_categories_on_ancestry", using: :btree
  add_index "blog_categories", ["ancestry_depth"], name: "index_blog_categories_on_ancestry_depth", using: :btree

  create_table "blog_subscribers", force: true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "call_reminders", force: true do |t|
    t.string   "name"
    t.string   "phone_number"
    t.string   "website"
    t.string   "status"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
  end

  create_table "cities", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
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
    t.text     "title"
    t.text     "subtitle"
    t.text     "description"
    t.hstore   "meta_data"
    t.integer  "size",            default: 1
    t.integer  "parent_city_id"
  end

  add_index "cities", ["name"], name: "index_cities_on_name", using: :btree
  add_index "cities", ["parent_city_id"], name: "index_cities_on_parent_city_id", using: :btree
  add_index "cities", ["slug"], name: "index_cities_on_slug", unique: true, using: :btree
  add_index "cities", ["zip_code"], name: "index_cities_on_zip_code", using: :btree

  create_table "city_neighborhoods", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "slug"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "city_neighborhoods", ["city_id"], name: "index_city_neighborhoods_on_city_id", using: :btree
  add_index "city_neighborhoods", ["slug"], name: "index_city_neighborhoods_on_slug", using: :btree

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
    t.string   "course_name"
    t.string   "status"
    t.string   "deletion_reason"
    t.string   "type"
    t.integer  "associated_message_id"
    t.boolean  "certified"
    t.string   "slug"
    t.datetime "deleted_at"
    t.integer  "course_id"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["course_id"], name: "index_comments_on_course_id", using: :btree
  add_index "comments", ["status"], name: "index_comments_on_status", using: :btree
  add_index "comments", ["type", "status"], name: "index_comments_on_type_and_status", using: :btree

  create_table "comments_subjects", id: false, force: true do |t|
    t.integer "comment_id"
    t.integer "subject_id"
  end

  add_index "comments_subjects", ["comment_id", "subject_id"], name: "index_comments_subjects_on_comment_id_and_subject_id", using: :btree

  create_table "communities", force: true do |t|
    t.integer  "structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "communities", ["structure_id"], name: "index_communities_on_structure_id", using: :btree

  create_table "community_memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "community_id"
    t.datetime "last_notification_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "community_memberships", ["community_id"], name: "index_community_memberships_on_community_id", using: :btree
  add_index "community_memberships", ["user_id"], name: "index_community_memberships_on_user_id", using: :btree

  create_table "community_message_threads", force: true do |t|
    t.integer  "community_id"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mailboxer_conversation_id"
    t.integer  "community_membership_id"
    t.datetime "deleted_at"
    t.integer  "indexable_card_id"
  end

  add_index "community_message_threads", ["community_id"], name: "index_community_message_threads_on_community_id", using: :btree
  add_index "community_message_threads", ["community_membership_id"], name: "index_community_message_threads_on_community_membership_id", using: :btree
  add_index "community_message_threads", ["indexable_card_id"], name: "index_community_message_threads_on_indexable_card_id", using: :btree
  add_index "community_message_threads", ["mailboxer_conversation_id"], name: "index_community_message_threads_on_mailboxer_conversation_id", using: :btree

  create_table "contacts", force: true do |t|
    t.integer  "contactable_id",   null: false
    t.string   "contactable_type", null: false
    t.string   "name"
    t.string   "phone"
    t.string   "mobile_phone"
    t.string   "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "deleted_at"
  end

  create_table "courses", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "frequency"
    t.text     "description"
    t.text     "info"
    t.boolean  "is_individual"
    t.boolean  "cant_be_joined_during_year"
    t.integer  "structure_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "slug"
    t.integer  "place_id"
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "rating"
    t.text     "subjects_string"
    t.text     "parent_subjects_string"
    t.boolean  "no_class_during_holidays"
    t.boolean  "teaches_at_home"
    t.float    "price"
    t.integer  "price_group_id"
    t.string   "audience_ids"
    t.string   "level_ids"
    t.integer  "min_age_for_kid"
    t.integer  "max_age_for_kid"
    t.boolean  "on_appointment",             default: false
    t.boolean  "is_open_for_trial"
    t.boolean  "has_promotion"
    t.datetime "deleted_at"
    t.boolean  "accepts_payment"
    t.integer  "media_id"
    t.boolean  "no_trial"
  end

  add_index "courses", ["is_open_for_trial"], name: "index_courses_on_is_open_for_trial", using: :btree
  add_index "courses", ["place_id"], name: "index_courses_on_place_id", using: :btree
  add_index "courses", ["slug"], name: "index_courses_on_slug", unique: true, using: :btree
  add_index "courses", ["structure_id", "is_open_for_trial"], name: "index_courses_on_structure_id_and_is_open_for_trial", using: :btree
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

  create_table "crm_locks", force: true do |t|
    t.boolean  "locked",       default: false
    t.datetime "locked_at"
    t.integer  "structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "emailing_section_bridges", force: true do |t|
    t.integer "emailing_section_id"
    t.integer "structure_id"
    t.integer "media_id"
    t.boolean "is_logo"
    t.integer "subject_id"
    t.string  "subject_name"
    t.integer "review_id"
    t.string  "review_text"
    t.boolean "review_custom"
    t.string  "city_text"
    t.integer "indexable_card_id"
  end

  add_index "emailing_section_bridges", ["emailing_section_id", "structure_id"], name: "comments_subjects_index", using: :btree
  add_index "emailing_section_bridges", ["indexable_card_id"], name: "index_emailing_section_bridges_on_indexable_card_id", using: :btree

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
    t.string   "section_metadata_one"
    t.string   "section_metadata_two"
    t.string   "section_metadata_three"
    t.string   "header_image_alt"
    t.string   "header_url"
    t.string   "call_to_action_text"
    t.string   "call_to_action_url"
    t.string   "header_image"
  end

  create_table "emails", force: true do |t|
    t.string   "email"
    t.string   "email_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faq_questions", force: true do |t|
    t.integer  "faq_section_id"
    t.string   "question"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "faq_sections", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "slug"
    t.integer  "position"
    t.string   "type"
  end

  create_table "flyers", force: true do |t|
    t.boolean  "treated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
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

  create_table "gift_certificate_vouchers", force: true do |t|
    t.integer  "gift_certificate_id"
    t.string   "stripe_charge_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.float    "fee"
    t.float    "received_amount"
    t.boolean  "used",                default: false
  end

  add_index "gift_certificate_vouchers", ["gift_certificate_id"], name: "index_gift_certificate_vouchers_on_gift_certificate_id", using: :btree
  add_index "gift_certificate_vouchers", ["stripe_charge_id"], name: "index_gift_certificate_vouchers_on_stripe_charge_id", unique: true, using: :btree
  add_index "gift_certificate_vouchers", ["token"], name: "index_gift_certificate_vouchers_on_token", unique: true, using: :btree
  add_index "gift_certificate_vouchers", ["user_id"], name: "index_gift_certificate_vouchers_on_user_id", using: :btree

  create_table "gift_certificates", force: true do |t|
    t.integer  "structure_id"
    t.string   "name"
    t.float    "amount"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "gift_certificates", ["structure_id"], name: "index_gift_certificates_on_structure_id", using: :btree

  create_table "guide_answers", force: true do |t|
    t.integer  "guide_question_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "position"
  end

  add_index "guide_answers", ["guide_question_id"], name: "index_guide_answers_on_guide_question_id", using: :btree

  create_table "guide_answers_subjects", id: false, force: true do |t|
    t.integer "guide_answer_id"
    t.integer "subject_id"
  end

  add_index "guide_answers_subjects", ["guide_answer_id"], name: "index_guide_answers_subjects_on_guide_answer_id", using: :btree
  add_index "guide_answers_subjects", ["subject_id"], name: "index_guide_answers_subjects_on_subject_id", using: :btree

  create_table "guide_questions", force: true do |t|
    t.integer  "guide_id"
    t.integer  "ponderation"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "color"
  end

  add_index "guide_questions", ["guide_id"], name: "index_guide_questions_on_guide_id", using: :btree

  create_table "guides", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "call_to_action"
    t.boolean  "age_dependant",  default: false
    t.string   "image"
  end

  add_index "guides", ["slug"], name: "index_guides_on_slug", unique: true, using: :btree

  create_table "indexable_cards", force: true do |t|
    t.integer  "structure_id"
    t.integer  "place_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "slug"
    t.integer  "popularity"
  end

  add_index "indexable_cards", ["course_id"], name: "index_indexable_cards_on_course_id", using: :btree
  add_index "indexable_cards", ["place_id"], name: "index_indexable_cards_on_place_id", using: :btree
  add_index "indexable_cards", ["structure_id"], name: "index_indexable_cards_on_structure_id", using: :btree

  create_table "indexable_cards_subjects", id: false, force: true do |t|
    t.integer "indexable_card_id", null: false
    t.integer "subject_id",        null: false
  end

  add_index "indexable_cards_subjects", ["indexable_card_id"], name: "index_indexable_cards_subjects_on_indexable_card_id", using: :btree
  add_index "indexable_cards_subjects", ["subject_id"], name: "index_indexable_cards_subjects_on_subject_id", using: :btree

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

  create_table "mailboxer_conversation_opt_outs", force: true do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  create_table "mailboxer_conversations", force: true do |t|
    t.string   "subject",                      default: ""
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "mailboxer_label_id"
    t.boolean  "treated_by_phone",             default: false
    t.datetime "treated_at"
    t.string   "flagged"
    t.datetime "flagged_at"
    t.string   "mailboxer_extra_info_ids"
    t.string   "mailboxer_course_ids"
    t.integer  "participation_request_id"
    t.boolean  "lock_email_notification_once", default: false
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
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "format"
    t.string   "provider_id"
    t.string   "provider_name"
    t.text     "thumbnail_url"
    t.string   "type"
    t.string   "filepicker_url"
    t.boolean  "cover",                 default: false
    t.boolean  "star"
    t.string   "vertical_page_caption"
    t.boolean  "image_processing"
    t.string   "image"
    t.string   "remote_image_url"
    t.datetime "deleted_at"
  end

  add_index "medias", ["format"], name: "index_medias_on_format", using: :btree
  add_index "medias", ["mediable_id", "mediable_type"], name: "index_medias_on_mediable_id_and_mediable_type", using: :btree
  add_index "medias", ["mediable_id"], name: "index_medias_on_mediable_id", using: :btree
  add_index "medias", ["mediable_type"], name: "index_medias_on_mediable_type", using: :btree

  create_table "medias_subjects", id: false, force: true do |t|
    t.integer "subject_id"
    t.integer "media_id"
  end

  create_table "newsletter_bloc_ownerships", id: false, force: true do |t|
    t.integer "bloc_id"
    t.integer "sub_bloc_id"
  end

  add_index "newsletter_bloc_ownerships", ["bloc_id", "sub_bloc_id"], name: "index_newsletter_bloc_ownerships_on_bloc_and_sub_bloc", unique: true, using: :btree
  add_index "newsletter_bloc_ownerships", ["sub_bloc_id", "bloc_id"], name: "index_newsletter_bloc_ownerships_on_sub_bloc_and_bloc", unique: true, using: :btree

  create_table "newsletter_blocs", force: true do |t|
    t.string   "type"
    t.integer  "newsletter_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.text     "content"
  end

  add_index "newsletter_blocs", ["newsletter_id"], name: "index_newsletter_blocs_on_newsletter_id", using: :btree

  create_table "newsletter_mailing_lists", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "structure_id"
    t.hstore   "metadata"
  end

  add_index "newsletter_mailing_lists", ["structure_id"], name: "index_newsletter_mailing_lists_on_structure_id", using: :btree

  create_table "newsletter_metrics", force: true do |t|
    t.integer  "nb_email_sent", default: 0
    t.integer  "nb_opening",    default: 0
    t.integer  "nb_click",      default: 0
    t.integer  "newsletter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nb_bounced",    default: 0
  end

  add_index "newsletter_metrics", ["newsletter_id"], name: "index_newsletter_metrics_on_newsletter_id", using: :btree

  create_table "newsletter_recipients", force: true do |t|
    t.integer  "user_profile_id"
    t.integer  "newsletter_id"
    t.boolean  "opened",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mandrill_message_id"
    t.string   "mandrill_message_status"
    t.integer  "clicks"
    t.integer  "opens"
  end

  add_index "newsletter_recipients", ["newsletter_id"], name: "index_newsletter_recipients_on_newsletter_id", using: :btree
  add_index "newsletter_recipients", ["user_profile_id"], name: "index_newsletter_recipients_on_user_profile_id", using: :btree

  create_table "newsletters", force: true do |t|
    t.string   "title"
    t.string   "state",                      default: "draft"
    t.string   "email_object"
    t.string   "sender_name"
    t.string   "reply_to"
    t.integer  "structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "layout_id"
    t.datetime "sent_at"
    t.integer  "newsletter_mailing_list_id"
    t.string   "token"
  end

  add_index "newsletters", ["newsletter_mailing_list_id"], name: "index_newsletters_on_newsletter_mailing_list_id", using: :btree

  create_table "participation_request_invoices", force: true do |t|
    t.string   "stripe_invoice_id"
    t.datetime "payed_at"
    t.integer  "participation_request_id"
    t.datetime "deleted_at"
    t.boolean  "generated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participation_request_invoices", ["participation_request_id"], name: "index_participation_request_invoices_on_participation_request", using: :btree
  add_index "participation_request_invoices", ["stripe_invoice_id"], name: "index_participation_request_invoices_on_stripe_invoice_id", unique: true, using: :btree

  create_table "participation_request_participants", force: true do |t|
    t.integer  "number"
    t.datetime "deleted_at"
    t.integer  "participation_request_id"
    t.integer  "price_id"
  end

  add_index "participation_request_participants", ["participation_request_id", "price_id"], name: "participation_requests_participants_index", using: :btree

  create_table "participation_requests", force: true do |t|
    t.integer  "mailboxer_conversation_id"
    t.integer  "planning_id"
    t.integer  "user_id"
    t.integer  "structure_id"
    t.string   "state"
    t.string   "last_modified_by"
    t.date     "date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "course_id"
    t.integer  "cancelation_reason_id"
    t.integer  "report_reason_id"
    t.text     "report_reason_text"
    t.datetime "reported_at"
    t.integer  "old_course_id"
    t.boolean  "structure_responded",       default: false
    t.datetime "deleted_at"
    t.string   "street"
    t.string   "zip_code"
    t.integer  "city_id"
    t.boolean  "from_personal_website",     default: false
    t.string   "token"
    t.string   "stripe_charge_id"
    t.datetime "charged_at"
    t.datetime "refunded_at"
    t.float    "stripe_fee"
    t.boolean  "at_student_home",           default: false
    t.string   "treat_method"
  end

  add_index "participation_requests", ["stripe_charge_id"], name: "index_participation_requests_on_stripe_charge_id", unique: true, using: :btree

  create_table "participations_users", id: false, force: true do |t|
    t.integer "participation_id"
    t.integer "user_id"
  end

  add_index "participations_users", ["participation_id", "user_id"], name: "index_participations_users_on_participation_id_and_user_id", using: :btree

  create_table "phone_numbers", force: true do |t|
    t.string   "number"
    t.string   "phone_type"
    t.integer  "callable_id"
    t.string   "callable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "info"
  end

  add_index "phone_numbers", ["callable_id", "callable_type"], name: "index_phone_numbers_on_callable_id_and_callable_type", using: :btree
  add_index "phone_numbers", ["callable_id"], name: "index_phone_numbers_on_callable_id", using: :btree
  add_index "phone_numbers", ["callable_type"], name: "index_phone_numbers_on_callable_type", using: :btree

  create_table "places", force: true do |t|
    t.integer  "location_id"
    t.integer  "structure_id"
    t.text     "info"
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
    t.datetime "deleted_at"
  end

  add_index "places", ["structure_id"], name: "index_places_on_structure_id", using: :btree

  create_table "places_subjects", id: false, force: true do |t|
    t.integer "subject_id"
    t.integer "place_id"
  end

  add_index "places_subjects", ["subject_id", "place_id"], name: "index_places_subjects_on_subject_id_and_place_id", using: :btree

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
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "teacher_id"
    t.integer  "duration"
    t.string   "audience_ids"
    t.string   "level_ids"
    t.integer  "place_id"
    t.integer  "structure_id"
    t.boolean  "visible",               default: true
    t.boolean  "is_in_foreign_country", default: false
    t.datetime "deleted_at"
    t.integer  "indexable_card_id"
  end

  add_index "plannings", ["audience_ids"], name: "index_plannings_on_audience_ids", using: :btree
  add_index "plannings", ["course_id"], name: "index_plannings_on_course_id", using: :btree
  add_index "plannings", ["indexable_card_id"], name: "index_plannings_on_indexable_card_id", using: :btree
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
  end

  create_table "press_releases", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "slug"
    t.text     "content"
    t.boolean  "published"
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "price_groups", force: true do |t|
    t.string   "name"
    t.string   "course_type"
    t.text     "details"
    t.boolean  "premium_visible"
    t.integer  "structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "prices", force: true do |t|
    t.string   "libelle"
    t.decimal  "amount"
    t.integer  "course_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "nb_courses"
    t.decimal  "promo_amount"
    t.text     "info"
    t.string   "type"
    t.integer  "number"
    t.integer  "duration"
    t.integer  "price_group_id"
    t.string   "promo_amount_type"
    t.datetime "deleted_at"
  end

  add_index "prices", ["price_group_id"], name: "index_prices_on_price_group_id", using: :btree
  add_index "prices", ["type"], name: "index_prices_on_type", using: :btree

  create_table "ratp_lines", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "route_name"
    t.string   "color"
    t.string   "line_type"
  end

  create_table "ratp_positions", force: true do |t|
    t.integer  "ratp_line_id"
    t.integer  "ratp_stop_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratp_positions", ["ratp_line_id", "ratp_stop_id"], name: "index_ratp_positions_on_ratp_line_id_and_ratp_stop_id", unique: true, using: :btree
  add_index "ratp_positions", ["ratp_line_id"], name: "index_ratp_positions_on_ratp_line_id", using: :btree
  add_index "ratp_positions", ["ratp_stop_id"], name: "index_ratp_positions_on_ratp_stop_id", using: :btree

  create_table "ratp_stops", force: true do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "reply_tokens", force: true do |t|
    t.string   "token"
    t.string   "reply_type"
    t.hstore   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "used",       default: false
  end

  add_index "reply_tokens", ["token"], name: "index_reply_tokens_on_token", unique: true, using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sms_loggers", force: true do |t|
    t.string   "number"
    t.text     "text"
    t.string   "sender_type"
    t.integer  "sender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nexmo_message_id"
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

  create_table "stripe_events", force: true do |t|
    t.string   "stripe_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "event_type"
    t.datetime "deleted_at"
    t.boolean  "processed",       default: false
  end

  add_index "stripe_events", ["stripe_event_id"], name: "index_stripe_events_on_stripe_event_id", unique: true, using: :btree

  create_table "structure_duplicate_lists", force: true do |t|
    t.integer  "structure_id"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "structure_duplicate_lists", ["structure_id"], name: "index_structure_duplicate_lists_on_structure_id", using: :btree

  create_table "structure_indexable_locks", force: true do |t|
    t.integer  "structure_id"
    t.datetime "locked_at"
    t.boolean  "locked",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "structure_indexable_locks", ["structure_id"], name: "index_structure_indexable_locks_on_structure_id", using: :btree

  create_table "structures", force: true do |t|
    t.string   "structure_type"
    t.string   "name"
    t.string   "website"
    t.string   "contact_phone"
    t.string   "contact_mobile_phone"
    t.string   "contact_email"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "slug"
    t.string   "street"
    t.string   "zip_code"
    t.text     "description"
    t.integer  "city_id"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.text     "subjects_string"
    t.text     "parent_subjects_string"
    t.text     "facebook_url"
    t.boolean  "no_facebook"
    t.boolean  "no_website"
    t.integer  "crop_x",                                 default: 0
    t.integer  "crop_y",                                 default: 0
    t.integer  "crop_width",                             default: 500
    t.boolean  "has_only_one_place"
    t.string   "email_status"
    t.datetime "last_email_sent_at"
    t.string   "last_email_sent_status"
    t.string   "funding_type_ids"
    t.string   "widget_status"
    t.boolean  "teaches_at_home",                        default: false
    t.text     "widget_url"
    t.integer  "teaches_at_home_radius"
    t.hstore   "meta_data"
    t.integer  "highlighted_comment_id"
    t.string   "pricing_plan",                           default: "free"
    t.datetime "last_geocode_try"
    t.text     "sleeping_attributes"
    t.boolean  "logo_processing"
    t.string   "delivery_email_status"
    t.string   "logo"
    t.string   "sleeping_logo"
    t.string   "remote_logo_url"
    t.text     "course_subjects_string"
    t.boolean  "premium"
    t.boolean  "sms_opt_in",                             default: false
    t.integer  "principal_mobile_id"
    t.datetime "deleted_at"
    t.boolean  "pure_player",                            default: false
    t.string   "stripe_customer_id"
    t.string   "stripe_managed_account_id"
    t.string   "stripe_managed_account_secret_key"
    t.string   "stripe_managed_account_publishable_key"
    t.boolean  "enabled",                                default: true
    t.boolean  "show_trainings_first",                   default: true
    t.integer  "admin_id"
    t.integer  "comments_count",                         default: 0
  end

  add_index "structures", ["admin_id"], name: "index_structures_on_admin_id", using: :btree
  add_index "structures", ["principal_mobile_id"], name: "index_structures_on_principal_mobile_id", using: :btree
  add_index "structures", ["slug"], name: "index_structures_on_slug", unique: true, using: :btree
  add_index "structures", ["stripe_customer_id"], name: "index_structures_on_stripe_customer_id", unique: true, using: :btree
  add_index "structures", ["stripe_managed_account_id"], name: "index_structures_on_stripe_managed_account_id", unique: true, using: :btree
  add_index "structures", ["stripe_managed_account_publishable_key"], name: "index_structures_on_stripe_managed_account_publishable_key", unique: true, using: :btree
  add_index "structures", ["stripe_managed_account_secret_key"], name: "index_structures_on_stripe_managed_account_secret_key", unique: true, using: :btree

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
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "slug"
    t.string   "ancestry"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "short_name"
    t.integer  "position"
    t.integer  "ancestry_depth",             default: 0
    t.text     "title"
    t.text     "description"
    t.text     "subtitle"
    t.text     "good_to_know"
    t.text     "needed_meterial"
    t.text     "tips"
    t.string   "image"
    t.text     "guide_description"
    t.text     "age_advice_younger_than_5"
    t.text     "age_advice_between_5_and_9"
    t.text     "age_advice_older_than_10"
  end

  add_index "subjects", ["ancestry_depth"], name: "index_subjects_on_ancestry_depth", using: :btree
  add_index "subjects", ["position"], name: "index_subjects_on_position", using: :btree
  add_index "subjects", ["slug"], name: "index_subjects_on_slug", unique: true, using: :btree

  create_table "subjects_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "subject_id"
  end

  add_index "subjects_users", ["user_id", "subject_id"], name: "index_subjects_users_on_user_id_and_subject_id", using: :btree

  create_table "subscriptions", force: true do |t|
    t.string   "stripe_subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "canceled_at"
    t.datetime "deleted_at"
    t.integer  "structure_id"
    t.integer  "subscriptions_plan_id"
    t.datetime "expires_at"
    t.hstore   "metadata"
    t.integer  "subscriptions_coupon_id"
    t.boolean  "paused",                  default: false
    t.datetime "trial_ends_at"
    t.datetime "coupon_ends_at"
    t.datetime "charged_at"
  end

  add_index "subscriptions", ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true, using: :btree
  add_index "subscriptions", ["structure_id"], name: "index_subscriptions_on_structure_id", using: :btree
  add_index "subscriptions", ["subscriptions_coupon_id"], name: "index_subscriptions_on_subscriptions_coupon_id", using: :btree
  add_index "subscriptions", ["subscriptions_plan_id"], name: "index_subscriptions_on_subscriptions_plan_id", using: :btree

  create_table "subscriptions_coupons", force: true do |t|
    t.string   "name"
    t.string   "stripe_coupon_id"
    t.string   "duration"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount"
    t.integer  "max_redemptions"
    t.integer  "duration_in_months"
    t.datetime "redeem_by"
  end

  create_table "subscriptions_invoices", force: true do |t|
    t.string   "stripe_invoice_id"
    t.datetime "payed_at"
    t.integer  "structure_id"
    t.integer  "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "generated",         default: false
  end

  add_index "subscriptions_invoices", ["structure_id"], name: "index_subscriptions_invoices_on_structure_id", using: :btree
  add_index "subscriptions_invoices", ["subscription_id"], name: "index_subscriptions_invoices_on_subscription_id", using: :btree

  create_table "subscriptions_plans", force: true do |t|
    t.string   "stripe_plan_id"
    t.string   "interval"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "trial_period_days"
    t.integer  "amount"
    t.string   "public_name"
    t.string   "plan_type"
  end

  add_index "subscriptions_plans", ["stripe_plan_id"], name: "index_subscriptions_plans_on_stripe_plan_id", unique: true, using: :btree

  create_table "subscriptions_sponsorships", force: true do |t|
    t.integer  "subscription_id"
    t.string   "sponsored_email",                        null: false
    t.boolean  "redeemed",               default: false
    t.datetime "deleted_at"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "redeeming_structure_id"
  end

  add_index "subscriptions_sponsorships", ["subscription_id"], name: "index_subscriptions_sponsorships_on_subscription_id", using: :btree

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
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "teachers", force: true do |t|
    t.string   "name"
    t.integer  "admin_id"
    t.integer  "structure_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.text     "description"
    t.datetime "deleted_at"
    t.string   "image"
  end

  add_index "teachers", ["structure_id"], name: "index_teachers_on_structure_id", using: :btree

  create_table "user_favorites", force: true do |t|
    t.integer  "structure_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "indexable_card_id"
  end

  add_index "user_favorites", ["indexable_card_id"], name: "index_user_favorites_on_indexable_card_id", using: :btree
  add_index "user_favorites", ["user_id", "structure_id"], name: "index_user_favorites_on_user_id_and_structure_id", using: :btree

  create_table "user_profile_imports", force: true do |t|
    t.binary   "data",                       null: false
    t.string   "filename"
    t.string   "mime_type"
    t.integer  "structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "newsletter_mailing_list_id"
  end

  add_index "user_profile_imports", ["newsletter_mailing_list_id"], name: "index_user_profile_imports_on_newsletter_mailing_list_id", using: :btree

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
    t.boolean "subscribed",                 default: true
    t.integer "newsletter_mailing_list_id"
  end

  add_index "user_profiles", ["newsletter_mailing_list_id"], name: "index_user_profiles_on_newsletter_mailing_list_id", using: :btree
  add_index "user_profiles", ["structure_id", "user_id"], name: "index_user_profiles_on_structure_id_and_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                         default: "",    null: false
    t.string   "encrypted_password",            default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "fb_avatar"
    t.string   "location"
    t.string   "slug"
    t.string   "gender"
    t.date     "birthdate"
    t.boolean  "email_opt_in",                  default: true
    t.string   "first_name"
    t.string   "last_name"
    t.string   "zip_code"
    t.string   "phone_number"
    t.integer  "city_id"
    t.text     "description"
    t.boolean  "email_promo_opt_in",            default: true
    t.boolean  "email_newsletter_opt_in",       default: true
    t.boolean  "email_passions_opt_in",         default: true
    t.boolean  "sms_opt_in",                    default: true
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.hstore   "meta_data"
    t.string   "email_status"
    t.string   "last_email_sent_at"
    t.string   "last_email_sent_status"
    t.boolean  "super_user",                    default: false
    t.string   "delivery_email_status"
    t.datetime "sign_up_at"
    t.string   "avatar"
    t.datetime "deleted_at"
    t.string   "stripe_customer_id"
    t.boolean  "community_notification_opt_in", default: true
    t.string   "token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  add_index "users", ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true, using: :btree

  create_table "vertical_pages", force: true do |t|
    t.string   "subject_name"
    t.text     "caption"
    t.text     "title"
    t.text     "content"
    t.text     "keywords"
    t.string   "slug"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "checked",                 default: false
    t.text     "comments"
    t.text     "sidebar_title"
    t.string   "image"
    t.string   "page_title"
    t.text     "page_description"
    t.boolean  "show_trainings_in_title", default: false
    t.integer  "homepage_position"
    t.integer  "depth"
  end

  create_table "website_page_articles", force: true do |t|
    t.integer  "website_page_id"
    t.string   "slug"
    t.string   "title"
    t.text     "content"
    t.datetime "deleted_at"
  end

  add_index "website_page_articles", ["website_page_id"], name: "index_website_page_articles_on_website_page_id", using: :btree

  create_table "website_pages", force: true do |t|
    t.integer  "structure_id"
    t.string   "slug"
    t.string   "title"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "website_pages", ["structure_id"], name: "index_website_pages_on_structure_id", using: :btree

  create_table "website_parameters", force: true do |t|
    t.string   "slug"
    t.string   "title"
    t.integer  "structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "presentation_text"
    t.string   "webmaster_email"
    t.datetime "webmaster_email_sent_at"
  end

  add_index "website_parameters", ["structure_id"], name: "index_website_parameters_on_structure_id", using: :btree

  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", name: "mb_opt_outs_on_conversations_id", column: "conversation_id"

  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", name: "notifications_on_conversation_id", column: "conversation_id"

  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", name: "receipts_on_notification_id", column: "notification_id"

end
