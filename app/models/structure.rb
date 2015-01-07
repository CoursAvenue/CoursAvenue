# encoding: utf-8
class Structure < ActiveRecord::Base
  include Concerns::HstoreHelper
  include Concerns::ActiveHashHelper
  include Concerns::HasDeliveryStatus
  include Concerns::IdentityCacheFetchHelper
  include StructuresHelper
  include HasSubjects
  include ActsAsCommentable
  include ActsAsGeolocalizable
  include ConversationsHelper
  include IdentityCache
  include Rails.application.routes.url_helpers
  include AlgoliaSearch

  acts_as_paranoid
  acts_as_tagger

  extend FriendlyId

  STRUCTURE_STATUS      = %w(SA SAS SASU EURL SARL)
  TRIAL_COURSES_POLICY  = %w(1_trial 2_trials 3_trials)
  STRUCTURE_TYPES       = ['structures.company',
                          'structures.independant',
                          'structures.association',
                          'structures.other']

  WIDGET_STATUS    = ['installed', 'remind_me', 'dont_want', 'need_help']

  friendly_id :slug_candidates, use: [:slugged, :finders]

  geocoded_by :geocoder_address unless Rails.env.test?

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :city

  has_many :invited_users             , foreign_key: :referrer_id, dependent: :destroy
  has_many :invited_teachers          , -> { where(type: 'InvitedUser::Teacher') }, class_name: 'InvitedUser', foreign_key: :referrer_id, dependent: :destroy
  has_many :invited_students          , -> { where(type: 'InvitedUser::Student') }, class_name: 'InvitedUser', foreign_key: :referrer_id, dependent: :destroy
  has_many :medias                    , as: :mediable
  has_many :phone_numbers             , as: :callable
  has_many :comments                  , -> { order('certified ASC, created_at DESC') }, as: :commentable, dependent: :destroy, class_name: 'Comment::Review'
  has_many :teachers                  , dependent: :destroy
  has_many :courses                   , dependent: :destroy
  has_many :plannings                 , through: :courses
  has_many :cities                    , through: :places
  has_many :participations            , through: :plannings
  has_many :reservations,         as: :reservable
  has_many :comment_notifications     , dependent: :destroy
  has_many :sticker_demands           , dependent: :destroy
  has_many :followings
  has_many :followers, through: :followings, source: :user

  has_many :price_groups              , dependent: :destroy
  has_many :prices                    , through: :price_groups
  has_many :orders, class_name: 'Order::Premium'
  has_many :participation_requests

  define_has_many_for :funding_type

  has_and_belongs_to_many :subjects

  has_many :user_profiles
  has_many :user_profile_imports
  has_many :users, through: :user_profiles

  has_many :emailing_section_bridges
  has_many :emailing_sections, through: :emailing_section_bridge

  has_many :places                   , dependent: :destroy
  has_many :admins                   , dependent: :destroy
  has_many :subscription_plans       , dependent: :destroy

  # The structure that is not modified when an admin takes control.
  has_one :sleeping_structure, class_name: 'Structure', foreign_key: :sleeping_structure_id

  # The structure that is editable by the admin.
  belongs_to :controled_structure, class_name: 'Structure', foreign_key: :sleeping_structure_id

  attr_reader :delete_logo, :logo_filepicker_url
  attr_accessible :structure_type, :street, :zip_code, :city_id,
                  :place_ids, :name, :info, :registration_info,
                  :website, :facebook_url,
                  :contact_email,
                  :description, :subject_ids, :active, # active: for tests profile, eg. L'atelier de Nima, etc.
                  :has_validated_conditions,
                  :validated_by, :logo, :remote_logo_url,
                  :funding_type_ids,
                  :crop_x, :crop_y, :crop_width,
                  :rating, :comments_count,
                  :no_facebook, :no_website, :has_only_one_place,
                  :email_status, :last_email_sent_at, :last_email_sent_status,
                  :widget_status, :widget_url, :sticker_status,
                  :teaches_at_home, :teaches_at_home_radius, # in KM
                  # "Name of the subject,slug-of-the-subject;Name,slug"
                  :subjects_string, :parent_subjects_string, :course_subjects_string,
                  :gives_group_courses, :gives_individual_courses,
                  :gives_non_professional_courses, :gives_professional_courses,
                  :highlighted_comment_id,
                  :deletion_reasons, :deletion_reasons_text,
                  :phone_numbers_attributes, :places_attributes, :other_emails, :last_geocode_try,
                  :is_sleeping, :sleeping_email_opt_in, :sleeping_email_opt_out_reason,
                  :order_recipient, :delivery_email_status, :trial_courses_policy,
                  :sleeping_structure, :premium, :cities_text

  accepts_nested_attributes_for :places,
                                 reject_if: :reject_places,
                                 allow_destroy: false

  accepts_nested_attributes_for :phone_numbers,
                                 reject_if: :reject_phone_number,
                                 allow_destroy: true


  # To store hashes into hstore
  store_accessor :meta_data, :gives_group_courses, :gives_individual_courses,
                             :plannings_count, :has_promotion, :has_free_trial_course, :has_promotion, :course_names, :open_course_names, :open_course_subjects,
                             :highlighted_comment_title, :min_price_libelle, :min_price_amount, :max_price_libelle, :max_price_amount,
                             :level_ids, :audience_ids, :busy,
                             :open_courses_open_places, :open_course_nb, :jpo_email_status, :open_course_plannings_nb,
                             :response_rate, :response_time, :gives_non_professional_courses, :gives_professional_courses,
                             :deletion_reasons, :deletion_reasons_text, :other_emails, :search_score, :search_score_updated_at,
                             :is_sleeping, :sleeping_email_opt_in, :sleeping_email_opt_out_reason, :promo_code_sent, :order_recipient


  define_boolean_accessor_for :meta_data, :has_promotion, :gives_group_courses, :gives_individual_courses,
                                          :has_free_trial_course, :has_promotion, :gives_non_professional_courses,
                                          :gives_professional_courses, :is_sleeping, :sleeping_email_opt_in, :promo_code_sent

  mount_uploader :logo, StructureLogoUploader

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name, presence: true
  validate  :subject_parent_and_children
  validates :name, :website, :facebook_url, length: { maximum: 255 }
  # validates :website, :facebook_url, :widget_url, url: true
  validate  :no_contacts_in_name

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_create :set_active_to_true

  after_create  :set_default_place_attributes
  after_create  :geocode  unless Rails.env.test?

  before_save   :strip_name
  before_save   :sanatize_description
  before_save   :encode_uris

  after_save    :update_open_for_trial_courses_if_neesds
  after_save    :geocode_if_needs_to            unless Rails.env.test?
  after_save    :subscribe_to_crm               if Rails.env.production?
  after_touch   :set_premium
  after_touch   :update_meta_datas
  after_touch   :update_cities_text

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  scope :is_open_for_trial   , -> { where(arel_table[:trial_courses_policy].matches('%_trial%') ) }
  scope :sleeping            , -> { where("meta_data -> 'is_sleeping' = 'true'") }
  scope :with_logo           , -> { where.not( logo: nil ) }
  scope :with_media          , -> { joins(:medias).uniq }
  scope :with_logo_and_media , -> { with_logo.with_media }

  ######################################################################
  # Algolia                                                            #
  ######################################################################
  algoliasearch per_environment: true do
    attribute :name, :slug
    add_attribute :search_score do
      self.search_score.try(:to_i)
    end

    add_attribute :is_sleeping do
      self.is_sleeping?
    end

    add_attribute :type do
      'structure'
    end
    add_attribute :url do
      structure_path(self, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
    end

    add_attribute :logo_url do
      self.logo.url(:small_thumb)
    end
    customRanking ['desc(search_score)', 'desc(is_sleeping)']
  end

  ######################################################################
  # Solr                                                               #
  ######################################################################
  searchable do

    integer :search_score do
      compute_search_score
    end

    integer :search_score_danse do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'danse'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_theatre_scene do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'theatre-scene'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_yoga_bien_etre_sante do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'yoga-sante-bien_etre'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_musique_chant do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'musique-chant'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_deco_mode_bricolage do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'deco-mode-bricolage'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_dessin_peinture_arts_plastiques do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'dessin-peinture-arts'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_sports_arts_martiaux do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'sports-arts-martiaux'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_cuisine_vins do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'cuisine-vins'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_photo_video do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'photo-video'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end
    integer :search_score_other do
      compute_search_score if search_score.blank?
      if self.courses.without_open_courses.flat_map(&:subjects).map(&:root).uniq.map(&:slug).include? 'other'
        self.search_score.to_i + 20
      else
        self.search_score
      end
    end

    integer :view_count
    integer :action_count

    text :name, boost: 5

    text :course_names do
      courses.map(&:name)
    end

    text :subjects, boost: 5 do
      subject_array = []
      self.subjects.uniq.each do |subject|
        subject_array << subject
        subject_array << subject.parent        if subject.parent
        subject_array << subject.grand_parent  if subject.grand_parent
      end
      subject_array.uniq.map(&:name)
    end

    string :email_status do
      if email_status.nil?
        email_status
      else
        'more_than_fifteen_recommendations'
      end
    end

    latlon :location, multiple: true do
      places.map do |place|
        Sunspot::Util::Coordinates.new(place.latitude, place.longitude)
      end
    end

    integer :id

    # Here we store event the subject at depth 2 for pro admin dashboard purpose.
    integer :subject_ids, multiple: true do
      subject_ids = []
      self.subjects.uniq.each do |subject|
        subject_ids << subject.id
        subject_ids << subject.parent.id if subject.parent
        subject_ids << subject.root.id if subject.root
      end
      subject_ids.compact.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      self.subjects.uniq.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.parent.slug if subject.parent
        subject_slugs << subject.root.slug if subject.root
      end
      subject_slugs.uniq
    end

    string :structure_type do
      self.structure_type.split('.').last if self.structure_type
    end

    integer :funding_type_ids, multiple: true

    boolean :is_open_for_trial do
      self.courses.open_for_trial.any?
    end

    boolean :premium

    boolean :has_premium_prices

    integer :nb_courses do
      courses.select(&:is_published?).count
    end

    integer :nb_comments do
      self.comments_count
    end
    boolean :has_comment do
      self.comments_count > 0
    end
    boolean :has_logo do
      self.logo?
    end

    boolean :medias_count do
      self.medias.count
    end

    boolean :is_sleeping do
      self.is_sleeping.present?
    end

    boolean :sleeping_email_opt_in
    boolean :active

    boolean :has_admin do
      self.has_admin?
    end

    string :zip_codes, multiple: true do
      (self.places.map(&:zip_code) << self.zip_code).uniq
    end

    double :jpo_score
  end

  handle_asynchronously :solr_index, queue: 'index' unless Rails.env.test?

  ######################################################################
  # Caching                                                            #
  ######################################################################

  cache_has_many :subjects, inverse_name: :structures

  # Also cache by slug, since we often access a structure by its slug with FriendlyId.
  cache_index :slug, unique: true

  ######################################################################
  # Email reminder                                                     #
  ######################################################################

  # Sends reminder depending on the email status of the structure
  # This method is called every week through admin_reminder rake task
  # (Executed on Heroku by the scheduler)
  #
  # @return nil
  def send_reminder
    return if self.main_contact.nil? or self.is_sleeping?
    if self.main_contact.monday_email_opt_in?
      if self.update_email_status.present?
        update_column :last_email_sent_at, Time.now
        update_column :last_email_sent_status, email_status
        AdminMailer.delay.send(self.email_status.to_sym, self)
      end
    end
  end


  # Sends an email if there are pending comments
  #
  # @return [type] [description]
  def remind_for_pending_comments
    AdminMailer.delay.remind_for_pending_comments(self)
  end

  # Thursday email
  # Only send if thursday email opt in is true
  def remind_for_widget
    if self.main_contact and self.main_contact.monday_email_opt_in?
      if widget_status.nil?
        AdminMailer.delay.remind_for_widget(self)
      end
    end
  end

  # Mail sent every thursday
  # It's sent only if 'monday_email_opt_in' is set to true
  # When? :
  #     Tous les jeudis tant qu'un cours / stage non complété (les mêmes 3 raisons du
  #     cadre bleu call to action : périmé, prix ou créneau manquant) OU pas de planning du tout
  # TODO: monday and thursday email have changed
  def remind_for_planning_outdated
    if self.main_contact and self.main_contact.monday_email_opt_in?
      # Don't send if there is a published course
      return if self.courses.without_open_courses.detect(&:is_published?)
      AdminMailer.delay.planning_outdated(self)
    end
  end

  # Update the email status of the structure
  def update_email_status
    email_status = nil
    if !self.profile_completed? or self.comments.empty? or self.courses.without_open_courses.empty? or self.medias.empty?
      email_status = 'incomplete_profile'
    else
      email_status = nil
    end
    update_column :email_status, email_status
    return email_status
  end

  ######################################################################
  # Email reminder END                                                 #
  ######################################################################

  def places_around(latitude, longitude, radius=3.5)
    places.reject do |place|
      Geocoder::Calculations.distance_between([latitude, longitude], [place.latitude, place.longitude], unit: :km) >= radius.to_i
    end
  end

  # Check wether a place is in a given bounding box
  # @param  south_west Array [latitude, longitude]
  # @param  north_east Array [latitude, longitude]
  #
  # @return Places
  def places_in_bounding_box(south_west, north_east)
    places.select do |place|
      south_west[0].to_f < (place.latitude || 0) and north_east[0].to_f > (place.latitude || 0) and
      south_west[1].to_f < (place.longitude || 0) and north_east[1].to_f > (place.longitude || 0)
    end
  end

  def update_comments_count
    if comments.accepted.count != comments_count
      update_column :comments_count, comments.accepted.count
      update_column :updated_at, Time.now
      index
    end
  end

  def contact_email
    if read_attribute(:contact_email).present?
      read_attribute(:contact_email)
    elsif admins.any?
      admins.first.email
    end
  end

  def contact_mobile_phone
    if read_attribute(:contact_mobile_phone).present?
      read_attribute(:contact_mobile_phone)
    elsif admins.any?
      admins.first.mobile_phone_number
    end
  end

  def contact_phone
    if read_attribute(:contact_phone).present?
      read_attribute(:contact_phone)
    elsif admins.any?
      admins.first.phone_number
    end
  end

  def has_admin?
    main_contact and main_contact.persisted?
  end

  def main_contact
    admins.first
  end

  def address
    "#{street}, #{city.name}"
  end

  def parent_subjects
    subjects.uniq.map(&:parent).uniq
  end

  def contact_name
    if admins.any?
      admins.first.name
    end
  end

  def description_for_meta
    description.gsub(/\r\n\r\n/, ' ').html_safe if description
  end

  def independant?
    structure_type == 'structures.independant'
  end

  def activate!
    self.active = true
    save
    places.each { |place| place.index }
  end

  def disable!
    self.active = false
    save
    courses.each do |course|
      course.active = false
      course.save
    end
  end

  def logo_geometry(style = :original)
    @geometry ||= {}
    begin
      if Rails.env.production?
        @geometry[style] ||= Paperclip::Geometry.from_file(logo.url(style))
      else
        @geometry[style] ||= Paperclip::Geometry.from_file(logo.path(style))
      end
    rescue
      geometry = Struct.new(:width, :height)
      if style == :original
        @geometry[style] = geometry.new(600, 600)
      elsif style == :large
        @geometry[style] = geometry.new(450, 450)
      else
        @geometry[style] = geometry.new(200, 200)
      end
    end
  end

  def ratio_from_original_from_large
    600.0 / 450.0
  end

  def crop_width
    logo_min_width = [logo_geometry.width, logo_geometry.height].min
    # if the crop is larger than the picture, return the nil
    if (read_attribute(:crop_width) + crop_x) > logo_min_width or
       (read_attribute(:crop_width) + crop_y) > logo_min_width
      nil
    elsif read_attribute(:crop_width) == 0
      logo_min_width
    else
      read_attribute(:crop_width)
    end
  end

  def has_cropping_attributes?
    return false if crop_width == 0
    !crop_x.blank? && !crop_y.blank? && !crop_width.blank?
  end

  def has_pending_comments?
    comments.pending.count > 0
  end

  # Tell if the profile is complete
  #
  # @return Boolean
  def profile_completed?
    logo? and description.present?
  end

  def has_installed_widget?
    widget_status == 'installed'
  end


  # Returns the image that goes aside of the profile page
  # If there are videos, they will be put in cover so we return the cover image
  # But if there is no video, we return the second image
  #
  # @return Media
  def side_cover_image
    if medias.videos.any?
      medias.images.cover.first
    else
      medias.images.reject{|image| image.cover? }.first
    end
  end

  # Returns the cover image if there is one, else the first image
  #
  # @return Media
  def cover_image
    medias.images.cover.first || medias.images.first
  end

  # Simulating relations
  def audiences
    return [] unless audience_ids.present?
    audience_ids.map{ |audience_id| Audience.find(audience_id) }
  end

  def audience_ids
    return [] unless meta_data and meta_data['audience_ids']
    meta_data['audience_ids'].split(',').map(&:to_i)
  end

  def levels
    return [] unless level_ids.present?
    level_ids.map{ |level_id| Level.find(level_id) }
  end

  def level_ids
    return [] unless meta_data and meta_data['level_ids']
    meta_data['level_ids'].split(',').map(&:to_i)
  end

  ######################################################################
  # Meta data update                                                   #
  ######################################################################
  def update_meta_datas
    self.plannings_count          = plannings.visible.future.count
    self.gives_group_courses      = courses.select{|course| !course.is_individual? }.any?
    self.gives_individual_courses = courses.select(&:is_individual?).any?
    self.has_promotion            = courses.detect(&:has_promotion?).present?
    self.has_free_trial_course    = courses.detect(&:has_free_trial_lesson?).present?
    self.course_names             = courses.map(&:name).uniq.join(', ')
    # Store level and audiences ids as coma separated string values: "1,3,5"
    self.level_ids                = (plannings.collect(&:level_ids) + courses.privates.collect(&:level_ids)).flatten.uniq.sort.join(',')
    self.audience_ids             = (plannings.collect(&:audience_ids) + courses.privates.collect(&:audience_ids)).flatten.uniq.sort.join(',')
    set_min_and_max_price
    compute_response_rate
    save(validate: false)
  end
  handle_asynchronously :update_meta_datas

  def set_min_and_max_price
    best_price           = prices.where(Price.arel_table[:type].not_eq('Price::Registration').and(Price.arel_table[:amount].gt(0))).order('amount ASC').first
    most_expensive_price = prices.where(Price.arel_table[:type].not_eq('Price::Registration').and(Price.arel_table[:amount].gt(0))).order('amount DESC').first

    if best_price
      self.min_price_libelle = best_price.localized_libelle
      self.min_price_amount  = best_price.amount
      if best_price != most_expensive_price
        self.max_price_libelle = most_expensive_price.localized_libelle
        self.max_price_amount  = most_expensive_price.amount
      else
        self.max_price_libelle = nil
        self.max_price_amount  = nil
      end
    end
  end

  # Tells if the structure is based in Paris and around
  #
  # TODO: use cache?
  # @return Boolean
  def parisian?
    return places.map(&:parisian?).include? true
  end


  # Tells if the structure has open courses plannings
  #
  # @return Boolean
  def has_open_course_plannings?
    courses.open_courses.each do |course|
      return true if course.plannings.any?
    end
    return false
  end

  # TODO this method doesn't actually work:
  # according to the rspec tests, the resulting
  # change to the user_profile leaves it with
  # ( tags.length + profile.tags.length * 2 ) tags
  # However, in practice it is returning the right
  # thing to the client.
  # TODO I think the problem is here: the tags are
  # being added in such a way that they do not show
  # up in a search
  def add_tags_on(user_profile, tags)
    tags = tags.split(',') if tags.is_a? String

    tag_list = user_profile.tags.map(&:name)
    tag_list = tag_list + tags
    tag(user_profile, with: tag_list.uniq.join(','), on: :tags)
    user_profile.delay.index # If we index right away, it won't index the last tags added...
  end

  def create_tag tag_name
    tag     = owned_tags.build name: tag_name
    tag.save
    tagging = owned_taggings.build
    tagging.context = 'tags'
    tagging.tag     =  tag
    return tagging.save
  end


  # Create or update a user profile for the current strucutre
  # If tag is given, then affect a tag to it
  # @param user User
  # @param tag=nil String
  #
  # @return nil
  def create_or_update_user_profile_for_user(user, tag=nil)
    user_profile = user_profiles.where(email: user.email).first_or_create
    user_profile.first_name = user.first_name   if user_profile.first_name.nil?
    user_profile.last_name  = user.last_name    if user_profile.last_name.nil?
    user_profile.phone      = user.phone_number if user_profile.phone.nil?
    add_tags_on(user_profile, tag) if tag
  end

  # Total nb JPO places given by the structure
  #
  # @return Integer nb_place
  def total_jpo_places
    courses.open_courses.map do |course|
      course.nb_participants_max * course.plannings.count
    end.reduce(&:+)
  end

  # Total nb places left by the structure
  #
  # @return Integer nb_place
  def total_jpo_places_left
    courses.open_courses.map do |course|
      course.plannings.map(&:places_left).reduce(&:+) || 0
    end.reduce(&:+)
  end

  def jpo_score
    return 0 if total_jpo_places.nil? or total_jpo_places == 0
    participations.not_canceled.count.to_f / total_jpo_places.to_f
  end

  def email_opt_in
    main_contact.email_opt_in
  end

  def email
    main_contact.email
  end

  # Compute the reponse rate of the main_contact
  #
  # @return Integer [0-100] that is the percentage. Ex: 67
  def compute_response_rate
    return if main_contact.nil?
    conversations = main_contact.mailbox.conversations.where(subject: I18n.t(Mailboxer::Label::INFORMATION.name))
    number_of_conversations = conversations.length
    if number_of_conversations == 0
      self.response_rate = nil
      save
      return nil
    else
      # Select conversations that have :
      # More than 1 message and the number of sender is more than 1. It will mean that there has been a response.
      number_of_conversations_with_answers = 0
      conversations.select do |conversation|
        # A conversation will be considered as treated if there is an answer OR
        # if there is the flag treated_by_phone
        if conversation.messages.map(&:sender).uniq.length > 1 or
          conversation.read_attribute(:treated_by_phone) == true
          number_of_conversations_with_answers += 1
        end
      end
      self.response_rate = ((number_of_conversations_with_answers.to_f / number_of_conversations.to_f) * 100).round
      save
      return response_rate
    end
  end

  # Compute the time between each response in hours
  #
  # @return Integer that is the average number of hours between each responses. Ex: 14
  def compute_response_time
    return if main_contact.nil?
    conversations      = main_contact.mailbox.conversations.where(subject: I18n.t(Mailboxer::Label::INFORMATION.name))
    if conversations.length == 0
      self.response_time = nil
      save
      return nil
    else
      # Select conversations that have :
      # More than 1 message and the number of sender is more than 1. It will mean that there has been a response.
      delta_hours = []
      conversations.select do |conversation|
        # We consider treated_by_phone status to be faster because user can set this flag
        # only if the message haven't been answered
        if conversation.read_attribute(:treated_by_phone) == true
          first_message_created_at = conversation.messages.order('created_at ASC').first.created_at
          delta = ( (conversation.read_attribute(:treated_at) - first_message_created_at).abs.round / 60 ) / 60
        elsif conversation.messages.count > 1
          first_message_of_admin = conversation.messages.order('created_at ASC').detect{|m| m.sender.is_a? Admin }
          first_message_of_user  = conversation.messages.order('created_at ASC').detect{|m| m.sender.is_a? User }
          next if first_message_of_admin.nil? or first_message_of_user.nil?
          creation_dates = [first_message_of_admin.created_at, first_message_of_user.created_at]
          # (Time 1 - Time 2) => number of seconds between the two times
          # / 60 => To minutes | / 60 to hours
          delta = ((creation_dates[1] - creation_dates[0]).abs.round / 60) / 60
        end
        delta_hours << delta if delta
      end
      self.response_time = (delta_hours.reduce(&:+).to_f / (delta_hours.length.to_f)).round if delta_hours.any?
      save
      return response_time
    end
  end

  # Return current (last) subscription plan
  #
  # @return SubscriptionPlan or nil if there is no current SubscriptionPlan
  def subscription_plan
    subscription_plan = subscription_plans.order('created_at DESC').first
    return subscription_plan
  end

  #
  # Return similar profiles
  # /!\ DO NOT CHANGE LIMIT, it could harm someone...
  # limit     - Number of similar profile that will be returned
  # _params   - Params of the search, {} by default
  #
  # @return Array [Structure]
  def similar_profiles(limit=3, _params={})
    StructureSearch.similar_profile(self, limit, _params)
  end

  # Return highlighted comment if has one
  #
  # @return Comment
  def highlighted_comment
    Comment::Review.find(highlighted_comment_id) if highlighted_comment_id
  end

  #
  # Set the highlighted comment
  # @param comment Comment to hightlight
  #
  # @return Boolean if saved or not
  def highlight_comment! comment
    self.highlighted_comment_id = comment.id
    save
  end

  # Return wether the structure has any premium prices
  #
  # @return Boolean
  def has_premium_prices
    # [false, true].any?  # => true
    # [false, false].any? # => false
    price_groups.map(&:has_premium_prices?).any?
  end

  # Return main admin mailbox
  #
  # @return Mailbox
  def mailbox
    return nil if main_contact.nil?
    return @mailbox if @mailbox
    return @mailbox = main_contact.mailbox
  end

  # Return all conversations that are information demand AND are unanswered
  #
  # @return Mailboxer::Conversation
  def unanswered_information_message
    return [] if mailbox.nil?
    mailbox.conversations.where(Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])).select do |conversation|
      conversation_waiting_for_reply = Rails.cache.fetch [conversation, "structure/unanswered_information_message/conversation_waiting_for_reply"] do
        conversation_waiting_for_reply?(conversation)
      end
      conversation_waiting_for_reply
    end
  end

  # Return all the Metric associated with this structure
  #
  # @return The Metric
  def metrics
    Metric.where(structure_id: id)
  end

  #
  # Number of view counts
  # @param days_ago=15 Integer number of days ago
  #
  # @return Integer, the number of view counts the last 15 days
  def view_count(days_ago=15)
    return Metric.view_count(self, Date.today - days_ago.days) || 0
  end

  #
  # Number of action counts
  # @param days_ago=15 Integer number of days ago
  #
  # @return Integer, the number of view counts the last 15 days
  def action_count(days_ago=15)
    return Metric.action_count(self, Date.today - days_ago.days) || 0
  end

  #
  # Number of impression counts
  # @param days_ago=15 Integer number of days ago
  #
  # @return Integer, the number of impression counts the last 15 days
  def impression_count(days_ago=15)
    return Metric.impression_count(self, Date.today - days_ago.days) || 0
  end

  SEARCH_SCORE_COEF = {
    :medias         => 3,
    :plannings      => 5,
    :ratings        => 3,
    :logo           => 2,
    :response_rate  => 3,
    :response_time  => 3,
    :external_links => 1,
    :promotions     => 5
  }

  # Compute a search score for ordering
  #
  # See file 'Score de profil.xlsx' for more info
  # @return Integer
  def compute_search_score(force=false) # TODO when do we have to compute score ?
    # Return already stored search score if it has been computed recently
    if !force and search_score.present? and search_score_updated_at.present? and Date.parse(search_score_updated_at.to_s) > Date.yesterday
      return search_score
    else
      score = 0
      ## Medias
      if premium? and medias.count > 1
        score += (2 * SEARCH_SCORE_COEF[:medias])
      elsif (!premium? and medias.count > 1) or medias.count == 1
        score += (1 * SEARCH_SCORE_COEF[:medias])
      end
      ## Plannings
      if courses.detect(&:is_published?)
        if courses.select(&:is_published?).detect(&:price_group)
          score += (2 * SEARCH_SCORE_COEF[:plannings])
        else
          score += (1 * SEARCH_SCORE_COEF[:plannings])
        end
      end
      ## Ratings
      if comments_count > 15
        score += (3 * SEARCH_SCORE_COEF[:ratings])
      elsif comments_count > 5
        score += (2 * SEARCH_SCORE_COEF[:ratings])
      elsif comments_count > 0
        score += (1 * SEARCH_SCORE_COEF[:ratings])
      end
      ## Logo
      if logo.present?
        score += (1 * SEARCH_SCORE_COEF[:logo])
      end
      ## External_links
      if premium? and (facebook_url.present? or website.present?)
        score += (1 * SEARCH_SCORE_COEF[:external_links])
      end
      ## Response_rate
      if response_rate.nil? or response_rate.to_i >= 80
        score += (2 * SEARCH_SCORE_COEF[:response_rate])
      elsif response_rate and response_rate.to_i >= 50
        score += (1 * SEARCH_SCORE_COEF[:response_rate])
      end
      ## Response_time
      if response_time.nil? or response_time.to_i < 24
        score += (2 * SEARCH_SCORE_COEF[:response_time])
      elsif response_time and response_time.to_i < 120
        score += (1 * SEARCH_SCORE_COEF[:response_time])
      end
      ## Promotions
      if premium? and prices.select{|p| p.promo_amount.present?}.any?
        score += (2 * SEARCH_SCORE_COEF[:promotions])
      end

      self.search_score            = score
      self.search_score_updated_at = Time.now
      save(validate: false)
      return score
    end
  end

  # Disables the sleeping structure and activates the current structure.
  #
  # @return Boolean saved or not
  def wake_up!
    self.is_sleeping = false
    self.active      = true
    save(validate: false)
    delay.index
    sleeping_structure.destroy if sleeping_structure
    AdminMailer.delay.you_have_control_of_your_account(self)
    true
  end

  #
  # Rollback with sleeping attributes
  # that CoursAvenue team has validated his profile.
  #
  # @return Boolean saved or not
  def return_to_sleeping_mode!

    phone_numbers.map(&:destroy)
    sleeping_structure.phone_numbers.each do |phone|
      phone_numbers.create(number: phone.number, phone_type: phone.phone_type)
    end

    self.places        = sleeping_structure.places.map(&:dup)
    self.subjects      = root_subjects_from_string(sleeping_structure) + child_subjects_from_string(sleeping_structure)
    self.logo          = sleeping_structure.logo

    teachers.map(&:destroy)
    courses.map(&:destroy)
    price_groups.map(&:destroy)
    medias.map(&:destroy)
    AdminMailer.delay.you_dont_have_control_of_your_account(self, main_contact.email)
    main_contact.delete

    sleeping_structure.destroy

    save
  end

  # If admin wanted to go premium, we send promo_code the day later only if
  # the structure is still not premium
  #
  # @return Boolean
  def send_promo_code!
    return if self.premium? or self.promo_code_sent?
    annual_promo_code  = PromotionCode.create(name: "-10% sur l'abonnement annuel", code_id: "GOPREMIUMANNUEL_#{id}", promo_amount: 47, plan_type: 'yearly', expires_at: Date.tomorrow ,max_usage_nb: 1, apply_until: Date.tomorrow)
    monthyl_promo_code = PromotionCode.create(name: "-20% sur le 1er mois d'abonnement", code_id: "GOPREMIUM_#{id}", promo_amount: 9, plan_type: 'monthly', expires_at: Date.tomorrow ,max_usage_nb: 1, apply_until: Date.tomorrow)
    AdminMailer.delay.premium_follow_up_with_promo_code(self, monthyl_promo_code, annual_promo_code)
    self.promo_code_sent = true
    save(validate: false)
    true
  end
  handle_asynchronously :send_promo_code!, :run_at => Proc.new { Date.tomorrow + 9.hours }

  # Return the most used subject or the root subjects that has the most childs.
  #
  # @return Subject at depth 0
  def dominant_root_subject
    Rails.cache.fetch ["Structure#dominant_root_subject", self] do
      active_courses = courses.includes(:subjects).active
      if active_courses.any? and (_subjects = active_courses.flat_map{ |c| c.subjects }).any?
        _subjects.group_by{ |subject| subject.root }.values.max_by(&:size).first.root
      else
        subjects.at_depth(2).group_by(&:root).values.max_by(&:size).try(:first).try(:root)
      end
    end
  end

  # @return
  def dominant_child_subject
    if courses.active.any? and (_subjects = courses.active.flat_map{ |c| c.subjects }).any?
      _subjects.group_by(&:name).values.max_by(&:size).first
    else
      subjects.at_depth(2).group_by(&:root).values.max_by(&:size).first
    end
  end

  # Return the most used city
  #
  # @return City
  def dominant_city
    if plannings.any?
      dominant_city_from_planning
    else
      ([city] + places.map(&:city)).group_by{ |c| c }.values.max_by(&:size).first
    end
  end

  # Duplicate Structure into a new structure that will be hidden.
  #
  # @return a new Structure
  def duplicate_structure
    unless sleeping_structure.present?
      sleeping_structure = dup

      phone_numbers.each do |phone|
        sleeping_structure.phone_numbers.build(number: phone.number, phone_type: phone.phone_type)
      end

      sleeping_structure.places        = places.map(&:dup)
      sleeping_structure.subjects      = root_subjects_from_string(self) + child_subjects_from_string(self)

      sleeping_structure.is_sleeping   = true
      sleeping_structure.save
      sleeping_structure.delay.index

      self.sleeping_structure          = sleeping_structure
      self.active = false

      save
    end

    sleeping_structure
  end

  def has_trial_courses?
    courses.open_for_trial.any?
  end

  def is_open_for_trial?
    return Rails.cache.fetch ['Structure#is_open_for_trial?', self] do
      courses.open_for_trial.any?
    end
  end

  private

  def update_cities_text
    update_column :cities_text, places.map(&:city).map(&:name).uniq.join(', ')
  end
  handle_asynchronously :update_cities_text

  def set_premium
    if subscription_plan.nil?
      update_column :premium, false
    else
      update_column :premium, subscription_plan.active?
    end
  end

  # Strip name if exists to prevent from name starting by a space
  #
  # @return name
  def strip_name
    self.name = name.strip if name
  end

  def slug_candidates
    [
      :name,
      [:name, :zip_code],
      [:name, :zip_code, :street],
    ]
  end

  def set_active_to_true
    self.active              = true
    self.gives_group_courses = true
  end

  def subscribe_to_crm
    CrmSync.update(self) if main_contact and Rails.env.production?
  end
  handle_asynchronously :subscribe_to_crm

  def encode_uris
    self.website      = URI.encode(URI.decode(website))      if website.present? and website_changed?
    self.facebook_url = URI.encode(URI.decode(facebook_url)) if facebook_url.present? and facebook_url_changed?
    self.widget_url   = URI.encode(URI.decode(widget_url))   if widget_url.present? and widget_url_changed?
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  # Validations
  # Check if subjects at depth 0 AND 2 has been added, else add errors on model.
  #
  # @return errors
  def subject_parent_and_children
    # Not using scope because subject are not saved in tests and that can fail
    if subjects.select{|subject| subject.depth == 0}.empty?
      errors.add(:subjects,          "Vous devez sélectionner au moins une discipline")
    end
    if subjects.select{|subject| subject.depth == 2}.empty?
      errors.add(:children_subjects, "Vous devez sélectionner au moins une sous discipline")
    end
  end

  # Only geocode if  lat and lng are nil
  def geocode_if_needs_to
    # Don't try to geocode if it has failed less than 5 seconds earlier.
    # It might be because of Google query limit
    return nil if last_geocode_try and (Time.now - last_geocode_try) < 5 # 5 seconds
    if latitude.nil? or longitude.nil?
      update_column :last_geocode_try, Time.now
      geocode
      # Save only if lat and lng have been set.
      # Prevent from infinite trying to save
      save(validate: false) if latitude.present? and longitude.present?
    end
  end

  # Remove unwanted character from the content
  #
  # @return nil
  def sanatize_description
    self.description = StringHelper.sanatize(description) if description.present?
    nil
  end

  #
  # Set street / ZipCode and City regarding the first place being created
  #
  # @return nil
  def set_default_place_attributes
    place = places.first
    update_column :street,   place.street   if place
    update_column :zip_code, place.zip_code if place
    update_column :city_id,  place.city.id  if place
    nil
  end

  def reject_places attributes
    persisted? and attributes[:zip_code].blank?
  end

  def reject_phone_number attributes
    exists = attributes[:id].present?
    # Destroy if phone_number exists and number is blank
    attributes.merge!({:_destroy => 1}) if exists and attributes[:number].blank?
    # Reject if price does't not exist yet and amount is nil
    return (!exists and attributes[:number].blank?)
  end

  # Remove any kind of contact info in the name
  # eg. it will remove www.danse.com
  #
  # @return nil
  def no_contacts_in_name
    return nil if name.nil?
    if name.match(/((?:[-a-z0-9]+\.)+[a-z]{2,4})(?: |\Z|,)/i) or name.match(/ point com( |$)/i)
      errors.add :name, "Le nom ne peut pas contenir votre site internet"
    end
    nil
  end

  # Set is_open_for_trial to false if trial_courses_policy changed and is set to nil
  #
  # @return nil
  def update_open_for_trial_courses_if_neesds
    if trial_courses_policy_changed? and trial_courses_policy.blank?
      courses.open_for_trial.map{ |c| c.is_open_for_trial = false; c.save }
    end
    nil
  end

  def dominant_city_from_planning
    plannings.map(&:place).flat_map(&:city).group_by { |c| c }.values.max_by(&:size).first ||
      courses.flat_map(&:places).flat_map(&:city).group_by { |c| c }.values.max_by(&:size).first
  end
end
