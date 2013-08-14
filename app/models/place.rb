# encoding: utf-8
class Place < ActiveRecord::Base
  belongs_to :location
  belongs_to :structure

  attr_accessible :location, :structure
end
