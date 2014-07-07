# encoding: utf-8
class Structure < ActiveRecord::Base
  include Concerns::HstoreHelper
  include Concerns::ActiveHashHelper
  include HasSubjects
  include ActsAsCommentable
  include ActsAsGeolocalizable
  include ConversationsHelper

  acts_as_paranoid
  acts_as_tagger

  extend FriendlyId

  STRUCTURE_STATUS = %w(SA SAS SASU EURL SARL)
  STRUCTURE_TYPES  = ['structures.company',
                      'structures.independant',
                      'structures.association',
                      'structures.other']

  WIDGET_STATUS    = ['installed', 'remind_me', 'dont_want', 'need_help']

  friendly_id :slug_candidates, use: [:slugged, :finders]

  geocoded_by :geocoder_address

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :city

  has_many :invited_users             , foreign_key: :referrer_id, dependent: :destroy
  has_many :invited_teachers          , -> { where(type: 'InvitedUser::Teacher') }, class_name: 'InvitedUser', foreign_key: :referrer_id, dependent: :destroy
  has_many :invited_students          , -> { where(type: 'InvitedUser::Student') }, class_name: 'InvitedUser', foreign_key: :referrer_id, dependent: :destroy
  has_many :medias                    , as: :mediable
  has_many :phone_numbers             , as: :callable
  has_many :comments                  , -> { order('created_at DESC') }, as: :commentable, dependent: :destroy, class_name: 'Comment::Review'
  has_many :teachers                  , dependent: :destroy
  has_many :courses                   , dependent: :destroy
  has_many :plannings                 , through: :courses
  has_many :cities                    , through: :places
  has_many :participations            , through: :plannings
  has_many :reservations,         as: :reservable
  has_many :comment_notifications     , dependent: :destroy
  has_many :sticker_demands           , dependent: :destroy
  has_many :statistics                , dependent: :destroy
  has_many :followings
  has_many :followers, through: :followings, source: :user

  has_many :price_groups              , dependent: :destroy
  has_many :prices                    , through: :price_groups
  has_many :orders

  define_has_many_for :funding_type

  has_and_belongs_to_many :subjects

  has_many :user_profiles
  has_many :user_profile_imports
  has_many :users, through: :user_profiles

  has_many :places                   , dependent: :destroy
  has_many :admins                   , dependent: :destroy
  has_many :subscription_plans       , dependent: :destroy

  attr_reader :delete_logo
  attr_accessible :structure_type, :street, :zip_code, :city_id,
                  :place_ids, :name, :info, :registration_info,
                  :website, :facebook_url,
                  :contact_email,
                  :description, :subject_ids, :active,
                  :has_validated_conditions,
                  :validated_by, :logo,
                  :funding_type_ids,
                  :crop_x, :crop_y, :crop_width,
                  :rating, :comments_count,
                  :no_facebook, :no_website, :has_only_one_place,
                  :email_status, :last_email_sent_at, :last_email_sent_status,
                  :widget_status, :widget_url, :sticker_status,
                  :teaches_at_home, :teaches_at_home_radius, # in KM
                  :subjects_string, :parent_subjects_string, # "Name of the subject,slug-of-the-subject;Name,slug"
                  :gives_group_courses, :gives_individual_courses,
                  :gives_non_professional_courses, :gives_professional_courses,
                  :highlighted_comment_id,
                  :deletion_reasons, :deletion_reasons_text,
                  :phone_numbers_attributes, :places_attributes, :other_emails, :last_geocode_try

  accepts_nested_attributes_for :places,
                                 reject_if: :reject_places,
                                 allow_destroy: false

  accepts_nested_attributes_for :phone_numbers,
                                 reject_if: :reject_phone_number,
                                 allow_destroy: true


  # To store hashes into hstore
  store_accessor :meta_data, :gives_group_courses, :gives_individual_courses,
                             :plannings_count, :has_promotion, :has_free_trial_course, :course_names, :open_course_names, :open_course_subjects,
                             :highlighted_comment_title, :min_price_libelle, :min_price_amount, :max_price_libelle, :max_price_amount,
                             :level_ids, :audience_ids, :busy,
                             :open_courses_open_places, :open_course_nb, :jpo_email_status, :open_course_plannings_nb,
                             :response_rate, :response_time, :gives_non_professional_courses, :gives_professional_courses,
                             :deletion_reasons, :deletion_reasons_text, :other_emails, :search_score, :search_score_updated_at


  define_boolean_accessor_for :meta_data, :has_promotion, :gives_group_courses, :gives_individual_courses,
                              :has_free_trial_course, :gives_non_professional_courses, :gives_professional_courses

  has_attached_file :logo,
                    styles: {
                      original: {
                        geometry: '600x600#',
                        processors: [:cropper_square]
                      },
                      large: '450x450',
                      thumb: {
                        geometry: '200x200#',
                        processors: [:cropper]
                        }
                      }

  validates_attachment_content_type :logo, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name, presence: true
  validate  :subject_parent_and_children
  validates :name, :website, :facebook_url, length: { maximum: 255 }
  validates :website, :facebook_url, :widget_url, url: true
  validate  :no_contacts_in_name

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_create :set_active_to_true

  after_create  :set_default_place_attributes
  after_create  :geocode

  after_touch   :update_email_status

  before_save   :strip_name
  before_save   :sanatize_description
  before_save   :encode_uris
  before_save   :reset_cropping_attributes, if: :logo_has_changed?


  after_save    :geocode_if_needs_to
  after_save    :update_email_status
  after_save    :subscribe_to_nutshell

  ######################################################################
  # Solr                                                               #
  ######################################################################
  searchable do
    integer :search_score do
      compute_search_score
    end

    integer :view_count

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

    boolean :premium

    boolean :has_premium_prices

    boolean :active do
      self.active
    end

    integer :nb_courses do
      courses.count
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
    boolean :has_admin do
      self.has_admin?
    end

    string :zip_codes, multiple: true do
      (self.places.map(&:zip_code) << self.zip_code).uniq
    end

    double :jpo_score

  end

  handle_asynchronously :solr_index unless Rails.env.test?

  ######################################################################
  # Email reminder                                                     #
  ######################################################################

  # Sends reminder depending on the email status of the structure
  # This method is called every week through admin_reminder rake task
  # (Executed on Heroku by the scheduler)
  #
  # @return nil
  def send_reminder
    return unless self.main_contact.present?
    if self.main_contact.monday_email_opt_in?
      if self.update_email_status.present?
        self.update_column :last_email_sent_at, Time.now
        self.update_column :last_email_sent_status, self.email_status
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
    if self.main_contact and self.main_contact.thursday_email_opt_in?
      if widget_status.nil?
        AdminMailer.delay.remind_for_widget(self)
      end
    end
  end

  # Update the email status of the structure
  def update_email_status
    email_status = nil
    if !self.logo.present?
      email_status = 'no_logo_yet'
    elsif !self.profile_completed?
      email_status = 'incomplete_profile'
    elsif self.comments_count == 0
      email_status = 'no_recommendations'
    elsif self.comments_count < 5
      email_status = 'less_than_five_recommendations'
    elsif self.courses.active.empty?
      email_status = 'planning_outdated'
    elsif self.comments_count < 15
      email_status = 'less_than_fifteen_recommendations'
    end
    self.update_column :email_status, email_status
    return email_status
  end

  def places_around(latitude, longitude, radius=2)
    places.reject do |place|
      Geocoder::Calculations.distance_between([latitude, longitude], [place.latitude, place.longitude], unit: :km) >= radius
    end
  end

  # Check wether a place is in a given bounding box
  # @param  south_west Array [latitude, longitude]
  # @param  north_east Array [latitude, longitude]
  #
  # @return Places
  def places_in_bounding_box(south_west, north_east)
    places.select do |place|
      south_west[0].to_f < place.latitude and north_east[0].to_f > place.latitude and
      south_west[1].to_f < place.longitude and north_east[1].to_f > place.longitude
    end
  end

  def update_comments_count
    if self.comments.accepted.count != self.comments_count
      self.update_column :comments_count, self.comments.accepted.count
      self.update_column :updated_at, Time.now
      self.index
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
    self.main_contact and self.main_contact.persisted?
  end

  def main_contact
    admins.first
  end

  def address
    "#{self.street}, #{self.city.name}"
  end

  def parent_subjects
    subjects.uniq.map(&:parent).uniq
  end

  def contact_name
    if self.admins.any?
      self.admins.first.name
    end
  end

  def description_for_meta
    self.description.gsub(/\r\n\r\n/, ' ').html_safe if self.description
  end

  def independant?
    structure_type == 'structures.independant'
  end

  def activate!
    self.active = true
    self.save
    self.places.each { |place| place.index }
  end

  def disable!
    self.active = false
    self.save
    self.courses.each do |course|
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
    # self.logo_geometry(:original).width / self.logo_geometry(style).width
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
    self.comments.pending.count > 0
  end

  # Tell if the profile is complete
  #
  # @return Boolean
  def profile_completed?
    self.logo? and self.description.present?
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
    if self.medias.videos.any?
      self.medias.images.cover.first
    else
      self.medias.images.reject{|image| image.cover? }.first
    end
  end

  # Returns the cover image if there is one, else the first image
  #
  # @return Media
  def cover_image
    self.medias.images.cover.first || self.medias.images.first
  end

  # Simulating relations
  def audiences
    return [] unless audience_ids.present?
    self.audience_ids.map{ |audience_id| Audience.find(audience_id) }
  end

  def audience_ids
    return [] unless meta_data and meta_data['audience_ids']
    meta_data['audience_ids'].split(',').map(&:to_i)
  end

  def levels
    return [] unless level_ids.present?
    self.level_ids.map{ |level_id| Level.find(level_id) }
  end

  def level_ids
    return [] unless meta_data and meta_data['level_ids']
    meta_data['level_ids'].split(',').map(&:to_i)
  end

  ######################################################################
  # Meta data update                                                   #
  ######################################################################
  def update_meta_datas
    self.plannings_count          = self.plannings.visible.future.count
    self.gives_group_courses      = self.courses.select{|course| !course.is_individual? }.any?
    self.gives_individual_courses = self.courses.select(&:is_individual?).any?
    self.has_promotion            = self.prices.select{|p| p.promo_amount.present?}.any?
    self.has_free_trial_course    = self.prices.trials.where(Price.arel_table[:amount].eq(nil).or(Price.arel_table[:amount].eq(0))).any?
    self.course_names              = self.courses.map(&:name).uniq.join(', ')
    self.highlighted_comment_title = (self.highlighted_comment ? self.highlighted_comment.title : comments.accepted.order('created_at DESC').first.try(:title))
    # Store level and audiences ids as coma separated string values: "1,3,5"
    self.level_ids                = self.plannings.collect(&:level_ids).flatten.sort.uniq.join(',')
    self.audience_ids             = self.plannings.collect(&:audience_ids).flatten.sort.uniq.join(',')
    self.set_min_and_max_price
    compute_response_rate
    # update_jpo_meta_datas
    self.save(validate: false)
  end
  handle_asynchronously :update_meta_datas

  def update_jpo_meta_datas
    self.open_course_plannings_nb = self.courses.active.open_courses.map(&:plannings).flatten.length
    self.open_course_nb           = self.courses.active.open_courses.count
    self.open_course_names        = self.courses.active.open_courses.map(&:name).uniq.join(', ')
    self.open_course_subjects     = self.courses.active.open_courses.map(&:subjects).flatten.map(&:name).uniq.join(', ')
    self.open_courses_open_places = self.courses.active.open_courses.map(&:plannings).flatten.map(&:places_left).reduce(&:+)
    self.save(validate: false)
  end

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
  # @return Boolean
  def parisian?
    is_parisian = self.zip_code.starts_with? '75','77','78','91','92','93','94','95'
    return true if is_parisian
    return self.places.map(&:parisian?).include? true
  end


  # Tells if the structure has open courses plannings
  #
  # @return Boolean
  def has_open_course_plannings?
    self.courses.open_courses.each do |course|
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
    self.tag(user_profile, with: tag_list.uniq.join(','), on: :tags)
    user_profile.delay.index # If we index right away, it won't index the last tags added...
  end

  def create_tag tag_name
    tag     = self.owned_tags.build name: tag_name
    tag.save
    tagging = self.owned_taggings.build
    tagging.context = 'tags'
    tagging.tag     =  tag
    return tagging.save
  end

  def create_user_profile_for_message(user)
    user_profile = self.user_profiles.where(email: user.email).first_or_create
    user_profile.first_name = user.first_name if user_profile.first_name.nil?
    user_profile.last_name  = user.last_name  if user_profile.last_name.nil?
    self.add_tags_on(user_profile, UserProfile::DEFAULT_TAGS[:contacts])
  end

  # Total nb JPO places given by the structure
  #
  # @return Integer nb_place
  def total_jpo_places
    self.courses.open_courses.map do |course|
      course.nb_participants_max * course.plannings.count
    end.reduce(&:+)
  end

  # Total nb places left by the structure
  #
  # @return Integer nb_place
  def total_jpo_places_left
    self.courses.open_courses.map do |course|
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
      self.save
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
      self.save
      return self.response_rate
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
      self.save
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
          creation_dates = conversation.messages.order('created_at ASC').limit(2).map(&:created_at)
          # (Time 1 - Time 2) => number of seconds between the two times
          # / 60 => To minutes | / 60 to hours
          delta = ((creation_dates[1] - creation_dates[0]).abs.round / 60) / 60
        end
        delta_hours << delta if delta
      end
      self.response_time = (delta_hours.reduce(&:+).to_f / delta_hours.length.to_f).round
      self.save
      return self.response_time
    end
  end

  # Return current (last) subscription plan
  #
  # @return SubscriptionPlan
  def subscription_plan
    self.subscription_plans.order('created_at DESC').first
  end

  # Tells wether or not the structure is premium
  #
  # @return Boolean
  def premium
    return false if self.subscription_plan.nil?
    return self.subscription_plan.active?
  end

  # Alias for premium
  def premium?
    self.premium
  end

  def similar_profiles(limit=3)
    StructureSearch.similar_profile(self, limit)
  end

  # Return highlighted comment if has one
  #
  # @return Comment
  def highlighted_comment
    self.comments.find(highlighted_comment_id) if highlighted_comment_id
  end

  #
  # Set the highlighted comment
  # @param comment Comment to hightlight
  #
  # @return Boolean if saved or not
  def highlight_comment! comment
    self.highlighted_comment_id = comment.id
    self.save
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
    mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).select do |conversation|
      conversation_waiting_for_reply?(conversation)
    end
  end

  #
  # Number of view counts
  #
  # @return Integer, the number of view counts the last 15 days
  def view_count
    return Statistic.view_count(self, Date.today - 15.days)
  end

  SEARCH_SCORE_COEF = {
    :medias         => 2,
    :plannings      => 3,
    :ratings        => 1,
    :logo           => 1,
    :external_links => 1,
    :response_time  => 1,
    :promotions     => 2
  }

  # Compute a search score for ordering
  #
  # See file 'Score de profil.xlsx' for more info
  # @return Integer
  def compute_search_score(force=false)
    # Return already stored search score if it has been computed recently
    if !force and self.search_score.present? and self.search_score_updated_at.present? and Date.parse(self.search_score_updated_at.to_s) > Date.yesterday
      return self.search_score
    else
      score = 0
      ## Medias
      if self.premium? and self.medias.count > 1
        score += (2 * SEARCH_SCORE_COEF[:medias])
      elsif (!self.premium? and self.medias.count > 1) or self.medias.count == 1
        score += (1 * SEARCH_SCORE_COEF[:medias])
      end
      ## Plannings
      if self.plannings.visible.future.count > 0
        courses = self.plannings.visible.future.map(&:course).select(&:price_group_id)
        if courses.length > 0
          score += (2 * SEARCH_SCORE_COEF[:plannings])
        else
          score += (1 * SEARCH_SCORE_COEF[:plannings])
        end
      end
      ## Ratings
      if self.comments_count > 15
        score += (3 * SEARCH_SCORE_COEF[:ratings])
      elsif self.comments_count > 5
        score += (2 * SEARCH_SCORE_COEF[:ratings])
      elsif self.comments_count > 1
        score += (1 * SEARCH_SCORE_COEF[:ratings])
      end
      ## Logo
      if self.logo.present?
        score += (1 * SEARCH_SCORE_COEF[:logo])
      end
      ## External_links
      if self.premium? and (self.facebook_url.present? or self.website.present?)
        score += (1 * SEARCH_SCORE_COEF[:external_links])
      end
      ## Response_time
      if self.response_rate and self.response_rate.to_i >= 80
        score += (2 * SEARCH_SCORE_COEF[:response_time])
      elsif self.response_rate and self.response_rate.to_i >= 50
        score += (1 * SEARCH_SCORE_COEF[:response_time])
      end
      ## Promotions
      if self.premium? and self.prices.select{|p| p.promo_amount.present?}.any?
        score += (2 * SEARCH_SCORE_COEF[:promotions])
      end

      self.search_score            = score
      self.search_score_updated_at = Time.now
      self.save
      return score
    end
  end

  private

  # Strip name if exists to prevent from name starting by a space
  #
  # @return name
  def strip_name
    self.name = self.name.strip if self.name
  end

  def logo_has_changed?
    self.logo.dirty?
  end

  def reset_cropping_attributes
    self.crop_width = 0 # not nil, because it'll fail when reprocessing image.
    self.crop_x     = 0
    self.crop_y     = 0
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

  def subscribe_to_nutshell
    NutshellUpdater.update(self) if self.main_contact and Rails.env.production?
  end
  handle_asynchronously :subscribe_to_nutshell, :run_at => Proc.new { 10.minutes.from_now }

  def encode_uris
    self.website      = URI.encode(URI.decode(self.website))      if website.present? and website_changed?
    self.facebook_url = URI.encode(URI.decode(self.facebook_url)) if facebook_url.present? and facebook_url_changed?
    self.widget_url   = URI.encode(URI.decode(self.widget_url))   if widget_url.present? and widget_url_changed?
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  def subject_parent_and_children
    # Not using scope because subject are not saved in tests and that can fail
    if self.subjects.select{|subject| subject.depth == 0}.empty?
      errors.add(:subjects,          "Vous devez sélectionner au moins une discipline")
    end
    if self.subjects.select{|subject| subject.depth == 2}.empty?
      errors.add(:children_subjects, "Vous devez sélectionner au moins une sous discipline")
    end
  end

  # Only geocode if  lat and lng are nil
  def geocode_if_needs_to
    # Don't try to geocode if it has failed less than 5 seconds earlier.
    # It might be because of Google query limit
    return nil if self.last_geocode_try and (Time.now - self.last_geocode_try) < 5 # 5 seconds
    if latitude.nil? or longitude.nil?
      self.update_column :last_geocode_try, Time.now
      self.geocode
      # Save only if lat and lng have been set.
      # Prevent from infinite trying to save
      self.save(validate: false) if latitude.present? and longitude.present?
    end
  end

  # Remove unwanted character from the content
  #
  # @return nil
  def sanatize_description
    self.description = StringHelper.sanatize(self.description) if self.description.present?
    nil
  end

  #
  # Set street / ZipCode and City regarding the first place being created
  #
  # @return nil
  def set_default_place_attributes
    place = places.first
    self.update_column :street,   place.street   if place
    self.update_column :zip_code, place.zip_code if place
    self.update_column :city_id,  place.city.id  if place
    nil
  end

  def reject_places attributes
    self.persisted? and attributes[:zip_code].blank?
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
    return nil if self.name.nil?
    if self.name.match(/((?:[-a-z0-9]+\.)+[a-z]{2,4})(?: |\Z)/i)
      self.errors.add :name, "Le nom ne peut pas contenir votre site internet"
    end
    nil
  end
end
