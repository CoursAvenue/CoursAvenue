# encoding: utf-8
class Structure < ActiveRecord::Base
  acts_as_paranoid

  include HasSubjects
  include ActsAsCommentable
  include ActsAsGeolocalizable

  extend FriendlyId
  friendly_id :name, use: :slugged

  acts_as_gmappable validation: false,
                    language: 'fr'

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

  attr_reader :delete_image, :delete_logo
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
                  :image, :logo,
                  :crop_x, :crop_y, :crop_width, :crop_height, :cropping,
                  :rating, :comments_count,
                  :no_facebook, :no_website, :has_only_one_place,
                  :email_status, :last_email_sent_at, :last_email_sent_status,
                  :funding_type_ids, :funding_types,
                  :widget_status, :widget_url, :sticker_status,
                  :teachers_at_home,
                  :subjects_string, :parent_subjects_string # "Name of the subject,slug-of-the-subject;Name,slug"

  has_attached_file :logo,
                    styles: {
                      large: '500x500',
                      thumb: {
                        geometry: '200x200#',
                        processors: [:cropper]
                        }
                      }

  has_attached_file :image,
                    styles: { wide: '800x480#', thumb: '200x200#', normal: '450x' }

  # validates_attachment_content_type :image,
  #                                   :content_type => ['image/jpeg',
  #                                                     'image/jpg',
  #                                                     'image/png',
  #                                                     'image/gif'], :message => "Les formats accepté sont : JPEG / JPG / PNG et GIF"


  belongs_to       :city
  belongs_to       :pricing_plan

  has_many :invited_teachers          , dependent: :destroy
  has_many :medias,   as: :mediable   , order: 'created_at ASC'
  has_many :comments, as: :commentable, dependent: :destroy, order: 'created_at DESC'
  has_many :students                  , dependent: :destroy
  has_many :teachers                  , dependent: :destroy
  has_many :courses                   , dependent: :destroy
  has_many :renting_rooms
  has_many :cities, through: :places
  has_many :reservations,         as: :reservable
  # has_many :rooms, through: :places
  has_and_belongs_to_many :subjects

  has_many :places                   , dependent: :destroy
  has_many :locations, through: :places

  has_many :admins                   , dependent: :destroy

  validates :name               , :presence   => true
  validates :street             , :presence   => true, on: :create
  validates :zip_code           , :presence   => true, numericality: { only_integer: true }, on: :create
  validates :city               , :presence   => true, on: :create
  validate :subject_parent_and_children


  # -------------------- Callbacks
  before_create    :set_active_to_true

  after_create     :set_free_pricing_plan
  # after_create     :create_place
  after_create     :delay_subscribe_to_mailchimp if Rails.env.production?
  after_save       :delay_subscribe_to_nutshell  if Rails.env.production?
  after_save       :update_email_status
  after_touch      :update_email_status

  after_update     :reprocess_logo, :if => :cropping?

  before_save      :replace_slash_n_r_by_brs
  before_save      :fix_website_url
  before_save      :fix_facebook_url
  before_save      :fix_widget_url
  before_save      :encode_uris

  # ------------------------------------------------------------------------------------ Search attributes
  searchable do

    text :name, boost: 5 do
      self.name
    end

    # text :teachers do
    #   self.teachers.map(&:name)
    # end

    # text :description

    # text :street

    # text :course_names do
    #   courses.map(&:name)
    # end

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
        subject_ids << subject.parent.id if subject.parent
      end
      subject_ids.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      self.subjects.uniq.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.parent.slug if subject.parent
      end
      subject_slugs.uniq
    end

    boolean :active do
      self.active
    end

    double :rating do
      self.rating
    end

    integer :nb_courses do
      courses.count
    end
    integer :nb_comments do
      self.comments.count
    end
    boolean :has_comment do
      self.comments.count > 0
    end
    boolean :has_picture do
      self.image?
    end
    boolean :has_logo do
      self.logo?
    end
    boolean :has_admin do
      self.has_admin?
    end
  end

  handle_asynchronously :solr_index

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
    if self.main_contact.present? and self.email_status and self.main_contact.email_opt_in?
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

  def remind_for_widget
    if widget_status.nil?
      AdminMailer.delay.remind_for_widget(self)
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

  def locations_around(latitude, longitude, radius=5)
    locations.reject do |location|
      Geocoder::Calculations.distance_between([latitude, longitude], [location.latitude, location.longitude], unit: :km) >= radius
    end
  end

  def update_comments_count
    self.update_column :comments_count, self.comments.accepted.count
  end

  def contact_email
    if admins.any?
      admins.first.email
    else
      read_attribute(:contact_email)
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

  def description_for_input
    self.description.gsub(/<br>/, '&#x000A;').html_safe if self.description
  end

  def description_for_meta
    self.description.gsub(/<br>/, ' ').html_safe if self.description
  end

  def contact_name
    if self.admins.any?
      self.admins.first.name
    end
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
      @geometry[style] = geometry.new(100, 100)
    end
  end

  def ratio_from_original(style=:original)
    return 1 unless self.logo?
    self.logo_geometry(:original).width / self.logo_geometry(style).width
  end

  def has_cropping_attributes?
    !crop_x.blank? && !crop_y.blank? && !crop_width.blank? && !crop_height.blank?
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

  private

  def reprocess_logo
    self.update_column :cropping, false
    self.logo.reprocess!
  end

  def set_free_pricing_plan
    self.pricing_plan = PricingPlan.where(name: 'free').first unless self.pricing_plan.present?
  end

  def replace_slash_n_r_by_brs
    self.description = self.description.gsub(/\r\n/, '<br>') if self.description
  end

  def set_active_to_true
    self.active = true
  end

  def delay_subscribe_to_nutshell
    self.delay.subscribe_to_nutshell
  end

  def subscribe_to_nutshell
    NutshellUpdater.update(self)
  end

  def delay_subscribe_to_mailchimp
    self.delay.subscribe_to_mailchimp
  end

  def subscribe_to_mailchimp
    nb_comments = self.comments_count
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_TEACHERS_LIST_ID,
                           :email_address => self.contact_email,
                           :merge_vars => {
                              :NAME       => self.name,
                              :STATUS     => (self.admins.any? ? 'registered' : 'not registered'),
                              :NB_COMMENT => nb_comments,
                              :SLUG       => self.slug
                           },
                           :double_optin    => false,
                           :update_existing => true,
                           :send_welcome    => false})
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
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  def subject_parent_and_children
    errors.add(:subjects,          "Vous devez séléctionner au moins une discipline")        if self.subjects.select{|s| s.ancestry_depth == 0}.empty?
    errors.add(:children_subjects, "Vous devez séléctionner au moins une discipline enfant") if self.subjects.select{|s| s.ancestry_depth == 2}.empty?
  end
end
