# encoding: utf-8
class City < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_many :lived_places
  has_many :users, through: :lived_places

  has_many :places
  has_many :structures, through: :places
  has_many :courses   , through: :structures
  has_many :city_subject_infos

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name            , presence: true
  validates :zip_code        , presence: true
  validates :region_name     , presence: true
  validates :department_name , presence: true
  validates :commune_name    , presence: true
  validates :latitude        , presence: true
  validates :longitude       , presence: true

  attr_accessible :name, :image, :iso_code, :zip_code, :region_name, :region_code, :department_name,
                  :department_code, :commune_name, :commune_code, :latitude, :longitude, :acuracy,
                  :title, :subtitle, :description


  has_attached_file :image,
                    styles: { default: '900×600#', small: '250x200#'}
  validates_attachment_content_type :image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  def to_gmap_json
    {lng: self.longitude, lat: self.latitude}
  end

  def should_generate_new_friendly_id?
    new_record?
  end
end
