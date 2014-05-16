# encoding: utf-8
class Structure < ActiveRecord::Base
  extend ActiveHashHelper, HstoreHelper

  include HasSubjects
  include ActsAsCommentable
  include ActsAsGeolocalizable

  acts_as_paranoid
  acts_as_tagger

  extend FriendlyId

  STRUCTURE_STATUS        = %w(SA SAS SASU EURL SARL)
  STRUCTURE_TYPES         = ['structures.company',
                             'structures.independant',
                             'structures.association',
                             'structures.other']

  WIDGET_STATUS           = ['installed', 'remind_me', 'dont_want', 'need_help']

  friendly_id :slug_candidates, use: [:slugged, :finders]

  geocoded_by :geocoder_address

  attr_reader :delete_logo
  attr_accessible :structure_type, :street, :zip_code, :city_id,
                  :place_ids, :name, :info, :registration_info,
                  :website, :facebook_url, :contact_phone,
                  :contact_mobile_phone, :contact_email, :description,
                  :subject_ids,
                  :active,
                  :has_validated_conditions,
                  :validated_by,
                  :logo,
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
                  :highlighted_comment_id

  # To store hashes into hstore
  store_accessor :meta_data, :gives_group_courses, :gives_individual_courses,
                             :plannings_count, :has_promotion, :has_free_trial_course, :course_names, :open_course_names, :open_course_subjects,
                             :highlighted_comment_title, :min_price_libelle, :min_price_amount, :max_price_libelle, :max_price_amount,
                             :level_ids, :audience_ids, :busy,
                             :open_courses_open_places, :open_course_nb, :jpo_email_status, :open_course_plannings_nb,
                             :response_rate, :response_time, :gives_non_professional_courses, :gives_professional_courses


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
  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :city
  belongs_to :pricing_plan

  has_many :invited_users             , foreign_key: :referrer_id, dependent: :destroy
  has_many :invited_teachers          , -> { where(type: 'InvitedUser::Teacher') }, class_name: 'InvitedUser', foreign_key: :referrer_id, dependent: :destroy
  has_many :invited_students          , -> { where(type: 'InvitedUser::Student') }, class_name: 'InvitedUser', foreign_key: :referrer_id, dependent: :destroy
  has_many :medias                    , -> { order('created_at ASC') },  as: :mediable
  has_many :comments                  , -> { order('created_at DESC') }, as: :commentable, dependent: :destroy
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
  has_many :prices                    , through: :price_group

  define_has_many_for :funding_type

  has_and_belongs_to_many :subjects

  has_many :user_profiles
  has_many :user_profile_imports
  has_many :users, through: :user_profiles

  has_many :places                   , dependent: :destroy

  has_many :admins

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name               , :presence   => true
  validates :street             , :presence   => true, on: :create
  validates :zip_code           , :presence   => true, numericality: { only_integer: true }, on: :create
  validates :city               , :presence   => true, on: :create
  validate :subject_parent_and_children
  validates :name, :website, :facebook_url, length: { maximum: 255 }

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_create :set_active_to_true

  after_create  :set_free_pricing_plan
  after_create  :geocode

  after_touch   :update_email_status

  before_save   :sanatize_description
  before_save   :fix_website_url
  before_save   :fix_facebook_url
  before_save   :fix_widget_url
  before_save   :encode_uris
  before_save   :reset_cropping_attributes, if: :logo_has_changed?

  after_save    :geocode_if_needs_to
  after_save    :update_email_status
  after_save    :delay_subscribe_to_nutshell
  # after_save    :delay_subscribe_to_mailchimp

  ######################################################################
  # Solr                                                               #
  ######################################################################
  searchable do
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
      locations.map do |location|
        Sunspot::Util::Coordinates.new(location.latitude, location.longitude)
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
      (self.places.map(&:location).map(&:zip_code) << self.zip_code).uniq
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

  def locations
    self.places.map(&:location)
  end

  def locations_around(latitude, longitude, radius=5)
    locations.reject do |location|
      Geocoder::Calculations.distance_between([latitude, longitude], [location.latitude, location.longitude], unit: :km) >= radius
    end
  end


  #
  #
  # @param  bbox_sw Array [latitude, longitude]
  # @param  bbox_ne Array [latitude, longitude]
  #
  # @return Locations
  def locations_in_bounding_box(bbox_sw, bbox_ne)
    locations.reject do |location|
      # ensure that the location really is completely inside the box
      is_in_bounds = true

      if nil != location.latitude && bbox_sw[0].to_f < location.latitude && location.latitude < bbox_ne[0].to_f
        if nil != location.longitude && bbox_sw[1].to_f < location.longitude && location.longitude < bbox_ne[1].to_f
          is_in_bounds = false
        end
      end

      is_in_bounds
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

  def create_place(place_name='Adresse principale')
    place_name = 'Adresse principale' if place_name.blank?
    location_street     = self.street.gsub(',', '%').gsub(' ', '%').gsub('é', '%').gsub('è', '%').gsub('ê', '%').strip
    location_zip_code   = self.zip_code
    if (loc = Location.where(Location.arel_table[:name].matches(place_name).and(Location.arel_table[:street].matches(location_street)).and(Location.arel_table[:zip_code].eq(location_zip_code))).first)
      location = loc
    else
      location = Location.create(name: place_name, street: self.street, city: self.city, zip_code: self.zip_code)
    end
    Place.create(structure: self, location: location)
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
    self.plannings_count          = self.plannings.future.count
    self.gives_group_courses      = self.courses.select{|course| !course.is_individual? }.any?
    self.gives_individual_courses = self.courses.select(&:is_individual?).any?
    # TODO
    # self.has_promotion            = self.prices.select{|p| p.promo_amount.present?}.any?
    # self.has_free_trial_course    = self.prices.trials.where(Price.arel_table[:amount].eq(nil).or(Price.arel_table[:amount].eq(0))).any?
    self.course_names              = self.courses.map(&:name).uniq.join(', ')
    self.highlighted_comment_title = (self.highlighted_comment ? self.highlighted_comment.title : comments.accepted.order('created_at DESC').first.try(:title))
    # Store level and audiences ids as coma separated string values: "1,3,5"
    self.level_ids                = self.plannings.collect(&:level_ids).flatten.sort.uniq.join(',')
    self.audience_ids             = self.plannings.collect(&:audience_ids).flatten.sort.uniq.join(',')
    # TODO
    # self.set_min_and_max_price
    compute_response_rate
    # update_jpo_meta_datas
    self.save(validate: false)
  end

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
  # @return Integer that is the percentage. Ex: 67
  def compute_response_rate
    return if main_contact.nil?
    conversations = main_contact.mailbox.conversations.where(subject: "Demande d'informations")
    number_of_messages = conversations.length
    if number_of_messages == 0
      self.response_rate = nil
      self.save
      return nil
    else
      # Select conversations that have :
      # More than 1 message and the number of sender is more than 1. It will mean that there has been a response.
      number_of_messages_with_answers = 0
      conversations.select do |conversation|
        number_of_messages_with_answers += 1 if conversation.messages.map(&:sender).uniq.length > 1
      end
      self.response_rate = ((number_of_messages_with_answers.to_f / number_of_messages.to_f) * 100).round
      self.save
      return self.response_rate
    end
  end

  # Compute the time between each response in hours
  #
  # @return Integer that is the average number of hours between each responses. Ex: 14
  def compute_response_time
    return if main_contact.nil?
    conversations = main_contact.mailbox.conversations.where(subject: "Demande d'informations")
    number_of_messages = conversations.length
    if number_of_messages == 0
      self.response_time = nil
      self.save
      return nil
    else
      # Select conversations that have :
      # More than 1 message and the number of sender is more than 1. It will mean that there has been a response.
      delta_hours = []
      conversations.select do |conversation|
        if conversation.messages.count > 1
          creation_dates = conversation.messages.order('created_at ASC').limit(2).map(&:created_at)
          # (Time 1 - Time 2) => number of seconds between the two times
          # / 60 => To minutes | / 60 to hours
          delta_hours << ((creation_dates[1] - creation_dates[0]).abs.round / 60) / 60
        end
      end
      self.response_time = (delta_hours.reduce(&:+).to_f / delta_hours.length.to_f).round
      self.save
      return self.response_time
    end
  end

  def premium?
    true
    # false
  end

  def similar_profiles
    StructureSearch.similar_profile(self, 3)
  end

  def highlighted_comment
    self.comments.find(highlighted_comment_id) if highlighted_comment_id
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

  def set_free_pricing_plan
    self.pricing_plan = PricingPlan.where(name: 'free').first unless self.pricing_plan.present?
  end

  def set_active_to_true
    self.active              = true
    self.gives_group_courses = true
  end

  def delay_subscribe_to_mailchimp
    MailchimpUpdater.delay.update(self) if self.main_contact and Rails.env.production?
  end

  def delay_subscribe_to_nutshell
    NutshellUpdater.update(self) if self.main_contact and Rails.env.production?
  end
  handle_asynchronously :delay_subscribe_to_nutshell, :run_at => Proc.new { 10.minutes.from_now }

  def fix_website_url
    self.website = URLHelper.fix_url(self.website) if self.website.present?
  end

  def fix_facebook_url
    self.facebook_url = URLHelper.fix_url(self.facebook_url) if self.facebook_url.present?
  end

  def fix_widget_url
    self.widget_url = URLHelper.fix_url(self.widget_url) if self.widget_url.present?
  end

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
    if latitude.nil? or longitude.nil?
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
    self.description = self.description.scan(/[[:print:]]|[[:space:]]/).join if self.description.present?
    nil
  end
end
