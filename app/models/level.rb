class Level < ActiveRecord::Base
  has_many :levelings
  has_many :courses,    :through => :levelings

  attr_accessible :name, :order

  validates :name, :presence   => true
  validates :name, :uniqueness => true

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
