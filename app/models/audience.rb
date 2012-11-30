class Audience < ActiveRecord::Base
  has_and_belongs_to_many :course_groups

  attr_accessible :name, :order

  validates :name, presence:   true
  validates :name, uniqueness: true

  def self.kid
    Audience.where{name == 'audience.kid'}.first
  end

  def self.teenage
    Audience.where{name == 'audience.teenage'}.first
  end

  def self.adult
    Audience.where{name == 'audience.adult'}.first
  end

  def self.senior
    Audience.where{name == 'audience.senior'}.first
  end

end
