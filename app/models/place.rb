# encoding: utf-8
class Place < ActiveRecord::Base
  belongs_to :location
  belongs_to :structure

  has_many :contacts, as: :contactable, dependent: :destroy

  attr_accessible :location, :structure
end
