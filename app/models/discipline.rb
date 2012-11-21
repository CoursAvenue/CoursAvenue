class Discipline < ActiveRecord::Base
  has_many :course

  attr_accessible :name

  validates :name, :presence   => true
  validates :name, :uniqueness => true

end
