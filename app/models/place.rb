# encoding: utf-8
class Place < ActiveRecord::Base
  METRO_STOP_MAX_DISTANCE = 0.5 # kms.

  acts_as_paranoid

  include ActsAsGeolocalizable

  geocoded_by :geocoder_address unless Rails.env.test?

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :city
  belongs_to :structure

  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :plannings, dependent: :destroy
  has_many :indexable_cards, dependent: :destroy
  has_and_belongs_to_many :subjects

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :affect_subjects

  before_save  :reindex_structure_and_places

  after_save   :geocode_if_needs_to unless Rails.env.test?
  after_save   :touch_relations
  before_destroy :update_structure_meta_datas

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :publics,                -> { where( type: 'Place::Public' ) }
  scope :homes,                  -> { where( type: 'Place::Home' ) }

  accepts_nested_attributes_for :contacts,
                                reject_if: lambda {|attributes| attributes.values.compact.reject(&:blank?).empty?},
                                allow_destroy: true

  attr_accessible :name, :type, :structure, :contacts,
                  :info, :private_info,
                  :contacts_attributes,
                  :street, :zip_code, :city, :city_id,
                  :latitude, :longitude, :gmaps, :radius, :last_geocode_try, :subject_ids

  def main_contact
    self.contacts.first
  end

  def parisian?
    return false if zip_code.nil?
    return self.zip_code.starts_with? '75','77','78','91','92','93','94','95'
  end

  def to_gmap_json
    { lng: self.longitude, lat: self.latitude }
  end

  def is_home?
    false
  end


  # Affect subjects to place if there is no subjects after creation
  #
  # @return nil
  def affect_subjects
    return if subjects.any?
    if structure.nil?
      destroy
      return
    end
    if plannings.any?
      self.subjects = plannings.flat_map{|planning| planning.course.subjects.at_depth(2) }.uniq
    else
      self.subjects = structure.subjects.at_depth(2).uniq
    end
    save
    nil
  end
  handle_asynchronously :affect_subjects

  # The Metro stops around self.
  #
  # @return an Array of Ratp::Stop.
  def nearby_metro_stops
    return [] if !latitude.present? or !longitude.present?

    Rails.cache.fetch ['Place#nearby_metro_stops', self] do
      Ratp::Stop.near([latitude, longitude], METRO_STOP_MAX_DISTANCE, units: :km)
    end
  end

  def dominant_root_subject
    subjects.at_depth(2).group_by(&:root).values.max_by(&:size).try(:first).try(:root)
  end

  def to_react_json
    {
        id:           id,
        latitude:     latitude,
        longitude:    longitude,
        subject_slug: dominant_root_subject.try(:slug),
        address:      address,
        radius:       radius
    }
  end

  def neighboroods
    Rails.cache.fetch ['Place#neighboroods/v1', self] do
      City::Neighborhood.near([latitude, longitude], 1, units: :km)
    end
  end

  private

  # Only geocode if :
  #     - lat and lng are nil
  #     - lat and lng didn't change but address changed
  #     - last geocode was more than 10 minutes ago
  def geocode_if_needs_to
    # Prevents from infinite loop
    return nil if self.last_geocode_try and (Time.now - self.last_geocode_try) < 10.minutes
    # Geocode only if...
    if (latitude.nil? and longitude.nil?) or street_changed? or zip_code_changed?
      self.update_column :last_geocode_try, Time.now
      self.geocode
      self.save(validate: false)
    end
    return nil
  end

  def reindex_structure_and_places
    if self.latitude_changed? or self.longitude_changed?
      self.structure.delay.index  if self.structure
    end
    self.plannings.map{ |planning| planning.delay.index }
  end

  def touch_relations
    self.structure.update_place_meta_datas
    self.plannings.map(&:touch)
    self.indexable_cards.map(&:touch)
  end
  handle_asynchronously :touch_relations

  def update_structure_meta_datas
    structure.delay.update_place_meta_datas
  end
end
