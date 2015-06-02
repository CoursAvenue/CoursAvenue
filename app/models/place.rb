# encoding: utf-8
class Place < ActiveRecord::Base
  acts_as_paranoid

  include ActsAsGeolocalizable

  geocoded_by :geocoder_address unless Rails.env.test?

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :city
  belongs_to :structure, touch: true

  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :plannings, dependent: :destroy
  has_many :indexable_cards, dependent: :destroy
  has_and_belongs_to_many :subjects

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :affect_subjects
  after_save   :reindex_structure_and_places
  after_save   :geocode_if_needs_to unless Rails.env.test?
  after_save   :touch_relations
  after_destroy :update_structure_meta_datas

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

  private

  # Only geocode if :
  #     - lat and lng are nil
  #     - lat and lng didn't change but address changed
  def geocode_if_needs_to
    # Prevents from infinite loop
    return nil if self.last_geocode_try and (Time.now - self.last_geocode_try) < 1 # 1 seconds
    # Geocode only if...
    if (latitude.nil? and longitude.nil?) or street_changed? or zip_code_changed?
      self.update_column :last_geocode_try, Time.now
      self.geocode
      self.save(validate: false)
    end
    return nil
  end
  handle_asynchronously :geocode_if_needs_to

  def reindex_structure_and_places
    self.structure.delay.index if self.structure
    self.plannings.map{ |planning| planning.delay.index }
  end
  handle_asynchronously :reindex_structure_and_places

  def touch_relations
    self.plannings.map(&:touch)
    self.indexable_cards.map(&:touch)
  end
  handle_asynchronously :touch_relations

  def update_structure_meta_datas
    self.structure.try(:update_meta_datas)
  end
end
