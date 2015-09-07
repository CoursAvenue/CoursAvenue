# encoding: utf-8
class City < ActiveRecord::Base
  extend FriendlyId
  include Concerns::HstoreHelper

  friendly_id :name, use: [:slugged, :finders]

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :parent_city, class_name: 'City'

  has_many :sub_cities, class_name: 'City', foreign_key: 'parent_city_id'
  has_many :neighborhoods
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

  attr_accessible :name, :iso_code, :zip_code, :region_name, :region_code, :department_name,
                  :department_code, :commune_name, :commune_code, :latitude, :longitude, :acuracy,
                  :title, :subtitle, :description,
                  :size # [1, 2, 3], small, medium, big. It will affect the aroundPrecision on Algolia search


  store_accessor            :meta_data, :associated_zip_codes
  define_array_accessor_for :meta_data, :associated_zip_codes

  ######################################################################
  # SOLR                                                               #
  ######################################################################
  # :nocov:
  searchable do
    integer :zip_codes, multiple: true do
      (self.associated_zip_codes + [self.zip_code]).uniq
    end
  end
  # :nocov:

  def description
    if read_attribute(:description).present?
      read_attribute(:description)
    elsif parent_city
      parent_city.description
    end
  end

  def subtitle
    if read_attribute(:subtitle).present?
      read_attribute(:subtitle)
    elsif parent_city
      parent_city.subtitle
    end
  end

  def to_gmap_json
    { lng: self.longitude, lat: self.latitude }
  end

  def should_generate_new_friendly_id?
    new_record?
  end
end
