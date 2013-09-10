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
                  :no_facebook, :no_website,

                  ## Moyen de financements possible :
                  :accepts_holiday_vouchers, :accepts_ancv_sports_coupon, :accepts_leisure_tickets,
                  :accepts_afdas_funding, :accepts_dif_funding, :accepts_cif_funding,

                  # For registration info
                  :has_registration_form, :needs_photo_id_for_registration, :needs_id_copy_for_registration,
                  :needs_medical_certificate_for_registration, # certificat médical de moins de 3 mois
                  :needs_insurance_attestation_for_registration, # attestation d'assurance

                  :siret, :tva_intracom_number, :structure_status, :billing_contact_first_name,
                  :billing_contact_last_name, :billing_contact_phone_number, :billing_contact_email,
                  :bank_name, :bank_iban, :bank_bic

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
                    #convert_options: { wide: '-interlace Line', thumb: '-interlace Line', normal: '-interlace Line' }

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
  # validates :structure_type     , :presence   => true
  validates :siret              , length: { maximum: 14 }#, numericality: { only_integer: true }


  # -------------------- Callbacks
  before_create    :set_active_to_true

  after_create     :set_free_pricing_plan
  # after_create     :create_place
  after_create     :create_courses_relative_to_subject
  after_create     :delay_subscribe_to_mailchimp if Rails.env.production?

  after_update     :reprocess_logo, :if => :cropping?

  before_save      :replace_slash_n_r_by_brs
  before_save      :fix_website_url
  before_save      :fix_facebook_url
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
        subject_array << subject.parent.parent if subject.parent and subject.parent.parent
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
      self.admins.any?
    end
  end

  handle_asynchronously :solr_index

  def locations_around(latitude, longitude, radius=5)
    locations.reject do |location|
      Geocoder::Calculations.distance_between([latitude, longitude], [location.latitude, location.longitude], unit: :km) > radius
    end
  end

  def update_comments_count
    self.update_column :comments_count, self.comments.count
  end

  def contact_email
    if admins.any?
      admins.first.email
    else
      read_attribute(:contact_email)
    end
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

  private

  def reprocess_logo
    self.update_column :cropping, false
    self.logo.reprocess!
  end

  def set_free_pricing_plan
    self.pricing_plan = PricingPlan.where(name: 'free').first unless self.pricing_plan.present?
  end


  def create_courses_relative_to_subject
    self.subjects.each do |subject|
      self.courses.create(name: subject.name, subject_ids: [subject.id], type: 'Course::Lesson', start_date: Date.today, end_date: (Date.today + 1.year))
    end
  end

  def replace_slash_n_r_by_brs
    self.description = self.description.gsub(/\r\n/, '<br>') if self.description
  end

  def set_active_to_true
    self.active = true
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

  def encode_uris
    self.website      = URI.encode(self.website)      if self.website.present?
    self.facebook_url = URI.encode(self.facebook_url) if self.facebook_url.present?
  end

  def should_generate_new_friendly_id?
    new_record? || !self.active
  end
end
