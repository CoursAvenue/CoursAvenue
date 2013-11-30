# encoding: utf-8
class Location < ActiveRecord::Base
  acts_as_paranoid

  include ActsAsGeolocalizable

  geocoded_by :geocoder_address
  after_validation :geocode

  before_save :set_shared

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

    string :name
    string :street
    boolean :shared do
      name != 'Adresse principale'
    end
  end

  def to_gmap_json
    {lng: self.longitude, lat: self.latitude}
  end

  private

  def set_shared
    self.shared = (name == 'Adresse principale')
    nil
  end
end
