class Level < ActiveRecord::Base
  has_and_belongs_to_many :courses

  attr_accessible :name, :order

  validates :name, :presence   => true
  validates :name, :uniqueness => true


  def self.all_levels
    Level.where(name: 'level.all').first
  end

  def self.initiation
    Level.where(name: 'level.initiation').first
  end

  def self.beginner
    Level.where(name: 'level.beginner').first
  end

  def self.intermediate
    Level.where(name: 'level.intermediate').first
  end

  def self.average
    Level.where(name: 'level.average').first
  end

  def self.advanced
    Level.where(name: 'level.advanced').first
  end

  def self.confirmed
    Level.where(name: 'level.confirmed').first
  end
end
