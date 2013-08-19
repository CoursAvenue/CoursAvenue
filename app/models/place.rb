# encoding: utf-8
class Place < ActiveRecord::Base
  belongs_to :location
  belongs_to :structure

  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :plannings

  accepts_nested_attributes_for :contacts
  accepts_nested_attributes_for :location

  attr_accessible :location, :structure, :contacts, :contacts_attributes, :location_attributes

  def belongs_to_other_locations?
    self.location.places.count > 1
  end

  def main_contact
    self.contacts.first
  end
end
