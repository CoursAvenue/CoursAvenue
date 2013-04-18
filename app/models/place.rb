class Place < ActiveRecord::Base
  unless Rails.env.test?
    acts_as_gmappable validation: false,
                      language: 'fr'
    before_save :retrieve_address
  end

  acts_as_paranoid

  extend FriendlyId
  friendly_id :friendly_name, use: [:slugged, :history]

  belongs_to :city
  belongs_to :structure
  has_many   :courses
  has_many   :rooms
  has_many   :comments, as: :commentable
  has_many   :subjects, through: :courses

  validates  :name      , presence: true
  validates  :street    , presence: true
  validates  :city      , presence: true
  validates  :zip_code  , presence: true, numericality: { only_integer: true }

  before_create :build_default_room

  has_attached_file :image,
                    :styles => { wide: "800x480#", thumb: "200x200#" }

  has_attached_file :thumb_image,
                    :styles => { wide: "400x400#", thumb: "200x200#" }

  attr_reader :delete_image
  attr_reader :delete_thumb_image
  attr_accessible :name,
                  :contact_email,
                  :contact_name,
                  :contact_phone,
                  :contact_mobile_phone,
                  :has_handicap_access,
                  :description,
                  :info, # Digicode, etc.
                  :image,
                  :thumb_image,
                  # :nb_room,
                  :street,
                  :zip_code,
                  :city,
                  :city_id,
                  :latitude,
                  :longitude,
                  :gmaps,
                  :has_handicap_access,
                  :has_cloackroom,
                  :has_internet,
                  :has_air_conditioning,
                  :has_swimming_pool,
                  :has_free_parking,
                  :has_jacuzzi,
                  :has_sauna,
                  :has_daylight

  def course_with_planning
    self.courses.joins{plannings}.where{plannings.end_date > Date.today}.group(:id)
  end

  # ------------------------------------------------------------------------------------ Search attributes
  searchable do
    text :name, :boost => 2
    text :structure_name, :boost => 2 do
      structure.name
    end


    text :street

    text :subjects do
      subject_array = []
      structure.subjects.each do |subject|
        subject_array << subject
        subject_array << subject.parent
      end
      subject_array.uniq.map(&:name)
    end

    string :street

    latlon :location do
      Sunspot::Util::Coordinates.new(self.latitude, self.longitude)
    end

    integer :subject_ids, multiple: true do
      subject_ids = []
      structure.subjects.each do |subject|
        subject_ids << subject.id
        subject_ids << subject.parent.id
      end
      subject_ids.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      structure.subjects.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.parent.slug
      end
      subject_slugs.uniq
    end

    boolean :active do
      self.structure.active
    end
  end

  def description
    if read_attribute(:description).present?
      read_attribute(:description)
    else
      structure.description
    end
  end

  # describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  def gmaps4rails_address
    "#{self.street}, #{self.zip_code}, France"
  end

  def retrieve_address
    if !self.new_record? and !self.is_geolocalized?
      begin
        geolocation    = Gmaps4rails.geocode self.gmaps4rails_address
        self.latitude  = geolocation[:lat]
        self.longitude = geolocation[:lng]
        self.save
      rescue Exception => e
        puts "Address not found: #{e}"
      end
    end
  end

  def is_geolocalized?
    !self.latitude.nil? and self.longitude.nil?
  end

  def geolocalize
    self.touch
    self.save
  end

  def address
    "#{self.street}, #{self.city.name}"
  end

  def long_name
    if self.name == self.structure.name
      self.name
    else
      "#{self.structure.name} - #{self.name}"
    end
  end

  def parent_subjects
    structure.subjects.uniq.map(&:parent).uniq
  end

  def to_gmap_json
    {lng: self.longitude, lat: self.latitude}
  end

  def contact_email
    unless read_attribute(:contact_email).present?
      self.structure.email_address
    else
      read_attribute(:contact_email)
    end
  end

  def contact_name
    unless read_attribute(:contact_name).present?
      self.structure.email_address
    else
      read_attribute(:contact_name)
    end
  end

  def contact_phone
    unless read_attribute(:contact_phone).present?
      self.structure.phone_number
    else
      read_attribute(:contact_phone)
    end
  end

  def contact_mobile_phone
    unless read_attribute(:contact_mobile_phone).present?
      self.structure.mobile_phone_number
    else
      read_attribute(:contact_mobile_phone)
    end
  end

  def rating
    if read_attribute(:rating)
      '%.1f' % read_attribute(:rating)
    else
      read_attribute(:rating)
    end
  end

  private
  def build_default_room
    if self.rooms.empty?
      self.rooms.build(name: I18n.t('rooms.main_room'))
    end
  end

  def friendly_name
    if self.structure.name == self.name
      self.name
    else
      "#{self.structure.name}-#{self.name}"
    end
  end

end
