# encoding: utf-8
class Location < ActiveRecord::Base
  acts_as_paranoid

  include ActsAsGeolocalizable

  geocoded_by      :geocoder_address
  after_validation :geocode_if_needs_to
  after_touch      :geocode_if_needs_to

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

    string :name
    string :street
  end

  def to_gmap_json
    { lng: self.longitude, lat: self.latitude }
  end

  private

  # Only geocode if lat and lng attributes haven't changed and are nil
  # Unless it means they have been set by the user
  def geocode_if_needs_to
    unless self.latitude_changed? and self.longitude_changed?
      unless self.geocoded? and !self.street_changed? and !self.zip_code_changed?
        self.geocode
      end
    end
  end

end
