class Discipline < ActiveRecord::Base
  has_ancestry

  has_many :courses
  attr_accessible :name

  validates :name, :presence   => true
  validates :name, :uniqueness => true

end
