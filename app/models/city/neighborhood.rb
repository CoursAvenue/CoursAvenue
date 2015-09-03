class City::Neighborhood < ActiveRecord::Base
  METRO_STOP_MAX_DISTANCE = 1.5 # kms.

  reverse_geocoded_by :latitude, :longitude

  extend FriendlyId
  include Concerns::HstoreHelper

  friendly_id :name, use: [:slugged, :finders]

  belongs_to :city

  attr_accessible :name, :description, :latitude, :longitude, :city_id,
                  :image, :remote_image_url

  mount_uploader :image, VerticalPageImageUploader

  def nearby_metro_stops
    Rails.cache.fetch ['City::Neighborhood#nearby_metro_stops/v1', self] do
      Ratp::Stop.near([latitude, longitude], METRO_STOP_MAX_DISTANCE, units: :km)
    end
  end
end
