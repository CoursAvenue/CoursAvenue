# class Level < ActiveHash::Base
#   include ActiveHash::Enum

#   self.data = [
#     { id: 0, short_name: 'All levels',   name: 'level.all',          order: 0},
#     { id: 1, short_name: 'Initiation',   name: 'level.initiation',   order: 1},
#     { id: 2, short_name: 'Beginner',     name: 'level.beginner',     order: 2},
#     { id: 3, short_name: 'Intermediate', name: 'level.intermediate', order: 3},
#     { id: 4, short_name: 'Confirmed',    name: 'level.confirmed',    order: 4},
#     { id: 5, short_name: 'Professional', name: 'level.professional', order: 5}
#   ]
#   enum_accessor :short_name
# end

class Level < ActiveRecord::Base

  has_and_belongs_to_many :plannings
  has_many :courses,   through: :plannings

  attr_accessible :name, :order

  def self.initiation
    Level.where(name: 'level.initiation').first
  end

  def self.beginner
    Level.where(name: 'level.beginner').first
  end

  def self.intermediate
    Level.where(name: 'level.intermediate').first
  end

  def self.confirmed
    Level.where(name: 'level.confirmed').first
  end
end
