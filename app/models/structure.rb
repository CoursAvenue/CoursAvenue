# encoding: utf-8
class Structure < ActiveRecord::Base
  acts_as_paranoid
  acts_as_tagger

  include HasSubjects
  include ActsAsCommentable
  include ActsAsGeolocalizable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  geocoded_by :geocoder_address
  after_validation :geocode

  after_save :delay_subscribe_to_nutshell

  STRUCTURE_STATUS        = %w(SA SAS SASU EURL SARL)
  STRUCTURE_TYPES         = ['structures.company',
                             'structures.independant',
                             'structures.association',
                             'structures.other']

  CANCEL_CONDITIONS       = ['structures.cancel_conditions.flexible',
                             'structures.cancel_conditions.moderate',
                             'structures.cancel_conditions.strict',
                             'structures.cancel_conditions.very_strict']

  MODIFICATION_CONDITIONS = ['structures.modification_conditions.flexible',
                             'structures.modification_conditions.moderate',
                             'structures.modification_conditions.strict']

  STICKER_STATUS          = []

  WIDGET_STATUS           = ['installed', 'remind_me', 'dont_want', 'need_help']

  attr_reader :delete_logo
  attr_accessible :structure_type, :street, :zip_code, :city_id,
                  :place_ids, :name, :info, :registration_info,
                  :gives_professional_courses, :website, :facebook_url, :contact_phone,
                  :contact_mobile_phone, :contact_email, :description,
                  :subject_ids,
                  :active,
                  :has_validated_conditions,
                  :validated_by,
                  :modification_condition,
                  :cancel_condition,
                  :logo,
                  :crop_x, :crop_y, :crop_width,
                  :rating, :comments_count,
                  :no_facebook, :no_website, :has_only_one_place,
                  :email_status, :last_email_sent_at, :last_email_sent_status,
                  :funding_type_ids, :funding_types,
                  :widget_status, :widget_url, :sticker_status,
                  :teaches_at_home, :teaches_at_home_radius, # in KM
                  :subjects_string, :parent_subjects_string # "Name of the subject,slug-of-the-subject;Name,slug"

  # To store hashes into hstore
  store_accessor :meta_data, :gives_group_courses, :gives_individual_courses,
                             :plannings_count, :has_promotion, :has_free_trial_course, :course_names,
                             :last_comment_title, :min_price_libelle, :min_price_amount, :max_price_libelle, :max_price_amount,
                             :level_ids, :audience_ids


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
  belongs_to :city
  belongs_to :pricing_plan

  has_many :invited_teachers          , dependent: :destroy
  has_many :medias                    , -> { order('created_at ASC') },  as: :mediable
  has_many :comments                  , -> { order('created_at DESC') }, as: :commentable, dependent: :destroy
  has_many :teachers                  , dependent: :destroy
  has_many :courses                   , dependent: :destroy
  has_many :plannings                 , through: :courses
  has_many :cities                    , through: :places
  has_many :prices                    , through: :courses
  has_many :reservations,         as: :reservable
  has_many :comment_notifications     , dependent: :destroy
  has_many :sticker_demands           , dependent: :destroy

  has_and_belongs_to_many :subjects

  has_many :user_profiles
  has_many :user_profile_imports
  has_many :users, through: :user_profiles

  has_many :places                   , dependent: :destroy

  has_many :admins

  validates :name               , :presence   => true
  validates :street             , :presence   => true, on: :create
  validates :zip_code           , :presence   => true, numericality: { only_integer: true }, on: :create
  validates :city               , :presence   => true, on: :create
  validate :subject_parent_and_children

  # -------------------- Callbacks
  before_create    :set_active_to_true

  after_create     :set_free_pricing_plan
  # after_create     :create_place
  after_save       :update_email_status
  after_touch      :update_email_status

  before_save      :fix_website_url
  before_save      :fix_facebook_url
  before_save      :fix_widget_url
  before_save      :encode_uris
  before_save      :reset_cropping_attributes, if: :logo_has_changed?

  # ------------------------------------
  # ------------------ Search attributes
  # ------------------------------------
  searchable do

    text :name, boost: 5

    # text :description

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

    # string :street

    latlon :location, multiple: true do
      locations.map do |location|
        Sunspot::Util::Coordinates.new(location.latitude, location.longitude)
      end
    end

    integer :subject_ids, multiple: true do
      subject_ids = []
      self.subjects.uniq.each do |subject|
        subject_ids << subject.id
        subject_ids << subject.root.id if subject.root
      end
      subject_ids.compact.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      self.subjects.uniq.each do |subject|
        subject_slugs << subject.slug
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
  end

  handle_asynchronously :solr_index unless Rails.env.test?

  # ---------------------------- Simulating Funding Type as objects
  def funding_type_ids= _funding_types
    if _funding_types.is_a? Array
      write_attribute :funding_type_ids, _funding_types.reject{|funding_type| funding_type.blank?}.join(',')
    else
      write_attribute :funding_type_ids, _funding_types
    end
  end

  def funding_types= _funding_types
    _funding_types.reject!(&:blank?)
    if _funding_types.is_a? Array
      write_attribute :funding_type_ids, _funding_types.join(',')
    elsif _funding_types.is_a? funding_type
      write_attribute :funding_type_ids, _funding_types.id.to_s
    end
  end

  def funding_types
    return [] unless funding_type_ids.present?
    self.funding_type_ids.map{ |funding_type_id| FundingType.find(funding_type_id) }
  end

  def funding_type_ids
    return [] unless read_attribute(:funding_type_ids)
    read_attribute(:funding_type_ids).split(',').map(&:to_i) if read_attribute(:funding_type_ids)
  end

  # ---------------------------------------------
  # Reminder
  # ---------------------------------------------

  # Send reminder every week depending on the email status of the structure
  def send_reminder
    if self.main_contact.present? and self.email_status and self.main_contact.monday_email_opt_in?
      if self.update_email_status.present?
        self.update_column :last_email_sent_at, Time.now
        self.update_column :last_email_sent_status, self.email_status
        AdminMailer.delay.send(self.email_status.to_sym, self)
      end
    end
  end

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
    if !self.profile_completed?
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

  # Params:
  #   bbox_sw: [latitude, longitude]
  #   bbox_ne: [latitude, longitude]
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
    if !read_attribute(:contact_email).blank?
      read_attribute(:contact_email)
    elsif admins.any?
      admins.first.email
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
    if (loc = Location.where{(name =~ place_name) & (street =~ location_street) & (zip_code == location_zip_code)}.first)
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

  def profile_completed?
    self.logo? and self.description.present?
  end

  def has_installed_widget?
    widget_status == 'installed'
  end

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

  # Augment methods to have them return boolean
  %w[has_promotion gives_group_courses gives_individual_courses has_free_trial_course].each do |key|
    scope "has_#{key}", ->(value) { where("meta_data @> hstore(?, ?)", key, value) }

    define_method("#{key}") do
      if meta_data && meta_data[key].present? then
        ActiveRecord::ConnectionAdapters::Column.value_to_boolean(meta_data[key])
      else
        nil
      end
    end
  end


  # Synced attributes
  def update_meta_datas
    self.plannings_count          = self.plannings.count
    self.gives_group_courses      = self.courses.select{|course| !course.is_individual? }.any?
    self.gives_individual_courses = self.courses.select(&:is_individual?).any?
    self.has_promotion            = self.prices.select{|p| p.promo_amount.present?}.any?
    self.has_free_trial_course    = self.prices.trials.where{(amount == nil) | (amount == 0)}.any?
    self.course_names             = self.courses.map(&:name).uniq.join(', ')
    self.last_comment_title       = self.comments.accepted.first.title if self.comments.accepted.any?
    # Store level and audiences ids as coma separated string values: "1,3,5"
    self.level_ids                = self.plannings.collect(&:level_ids).flatten.sort.uniq.join(',')
    self.audience_ids             = self.plannings.collect(&:audience_ids).flatten.sort.uniq.join(',')
    self.set_min_and_max_price
    self.save(validate: false)
  end

  def set_min_and_max_price
    best_price           = prices.where{(type != 'Price::Registration') & (amount > 0)}.order('amount ASC').first
    most_expensive_price = prices.where{(type != 'Price::Registration') & (amount > 0)}.order('amount DESC').first

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

  def delay_subscribe_to_nutshell
    self.delay.subscribe_to_nutshell
  end

  def parisian?
    paris_lat    = 48.8592
    paris_lng    = 2.3417
    paris_radius = 10
    Geocoder::Calculations.distance_between([paris_lat, paris_lng], [self.latitude, self.longitude], unit: :km) <= paris_radius
  end

  private

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
    self.active = true
  end

  def subscribe_to_nutshell
    NutshellUpdater.update(self)
  end

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
    self.website      = URI.encode(self.website)      if self.website.present?
    self.facebook_url = URI.encode(self.facebook_url) if self.facebook_url.present?
    self.widget_url   = URI.encode(self.widget_url)   if self.widget_url.present?
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  def subject_parent_and_children
    errors.add(:subjects,          "Vous devez sélectionner au moins une discipline")        if self.subjects.select{|s| s.ancestry_depth == 0}.empty?
    errors.add(:children_subjects, "Vous devez sélectionner au moins une sous discipline") if self.subjects.select{|s| s.ancestry_depth == 2}.empty?
  end
end
