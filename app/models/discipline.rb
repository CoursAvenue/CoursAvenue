class Discipline < ActiveRecord::Base
  has_ancestry

  has_many :course_groups
  attr_accessible :name

  validates :name, :presence   => true
  validates :name, :uniqueness => true

end
