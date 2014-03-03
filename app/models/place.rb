# encoding: utf-8
class Place < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :location, touch: true
  belongs_to :structure

  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :plannings, dependent: :destroy

  after_save :reindex_structure_and_places

  accepts_nested_attributes_for :contacts,
                                reject_if: lambda {|attributes| attributes.values.compact.reject(&:blank?).empty?},
                                allow_destroy: true

  accepts_nested_attributes_for :location


  attr_accessible :location, :structure, :contacts,
                  :info, :private_info,
                  :contacts_attributes,
                  :location_attributes

  validates :structure, :location, presence: true

  def main_contact
    self.contacts.first
  end

  def parisian?
    return false if self.location.nil? or self.location.zip_code.nil?
    return self.location.zip_code.starts_with? '75','77','78','91','92','93','94','95'
  end

  private

  def reindex_structure_and_places
    self.structure.index if self.structure
    self.plannings.map(&:index)
  end

end
