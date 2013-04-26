class Place < ActiveRecord::Base
  acts_as_paranoid

  unless Rails.env.test?
    acts_as_gmappable validation: false,
                      language: 'fr'
    before_save :retrieve_address
  end

  include ActsAsCommentable
  include ActsAsGeolocalizable
  include HasSubjects

  extend FriendlyId
  friendly_id :friendly_name, use: [:slugged, :history]

  belongs_to :city, touch: true
  belongs_to :structure, touch: true
  has_many   :courses
  has_many   :rooms
  has_many   :comments, as: :commentable
  has_many   :subjects, through: :courses

  validates  :name      , presence: true
  validates  :street    , presence: true
  validates  :city      , presence: true
  validates  :zip_code  , presence: true, numericality: { only_integer: true }

  has_attached_file :image,
                    :styles => { wide: "800x480#", thumb: "200x200#" }

  has_attached_file :thumb_image,
                    :styles => { wide: "400x400#", thumb: "200x200#" }

  attr_reader :delete_image
  attr_reader :delete_thumb_image
  attr_accessible :name,
                  :rating,
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
    self.courses.joins{plannings}.where{(active == true) & (plannings.end_date > Date.today)}.group(:id)
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
      if structure
        structure.subjects.each do |subject|
          subject_array << subject
          subject_array << subject.parent
        end
      end
      subject_array.uniq.map(&:name)
    end

    string :street

    latlon :location do
      Sunspot::Util::Coordinates.new(self.latitude, self.longitude)
    end

    integer :subject_ids, multiple: true do
      subject_ids = []
      if structure
        structure.subjects.each do |subject|
          subject_ids << subject.id
          subject_ids << subject.parent.id
        end
      end
      subject_ids.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      if structure
        structure.subjects.each do |subject|
          subject_slugs << subject.slug
          subject_slugs << subject.parent.slug
        end
      end
      subject_slugs.uniq
    end

    boolean :active do
      self.structure.active
    end

    double :rating
    integer :nb_courses do
      courses.count
    end
    integer :nb_comments do
      comments.count
    end
    boolean :has_comment do
      comments.count > 0
    end
  end

  def description
    if read_attribute(:description).present?
      read_attribute(:description)
    else
      structure.description
    end
  end

  def long_name
    if self.name == self.structure.name
      self.name
    else
      "#{self.structure.name} - #{self.name}"
    end
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


 def parent_subjects
   subjects.uniq.map(&:parent).uniq
 end

  private
  def friendly_name
    if self.structure.name == self.name
      self.name
    else
      "#{self.structure.name}-#{self.name}"
    end
  end

end
