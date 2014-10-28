# encoding: utf-8
# TODO Remove this class
class Location < ActiveRecord::Base
  acts_as_paranoid

  include ActsAsGeolocalizable

  geocoded_by :geocoder_address unless Rails.env.test?
  after_save  :geocode_if_needs_to

  belongs_to :city

  has_many :places
  has_many :structures, through: :places

  validates  :name     , presence: true
  validates  :street   , presence: true
  validates  :city     , presence: true
  validates  :zip_code , presence: true, numericality: { only_integer: true }


  attr_accessible :name,
                  :shared,
                  :street, :zip_code, :city, :city_id,
                  :latitude, :longitude, :gmaps,
                  :contact_email, :contact_name, :contact_phone, :contact_mobile_phone

  # ------------------------------------------------------------------------------------ Search attributes
  searchable do
    text :name
    text :street
    text :zip_code
    text :city do
      self.city.name
    end

    latlon :location do
      Sunspot::Util::Coordinates.new(self.latitude, self.longitude)
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      self.structures.map(&:subjects).flatten.uniq.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.root.slug if subject.root
      end
      subject_slugs.uniq
    end

    string :name
    string :street
  end
  handle_asynchronously :solr_index, queue: 'index' unless Rails.env.test?

  def to_gmap_json
    { lng: self.longitude, lat: self.latitude }
  end

  private

  # Only geocode if :
  #     - lat and lng are nil
  #     - lat and lng didn't change but address changed
  def geocode_if_needs_to
    if (latitude.nil? and longitude.nil?) or (!latitude_changed? and !longitude_changed? and street_changed? and zip_code_changed?)
      self.geocode
      self.save(validate: false)
    end
  end
end
