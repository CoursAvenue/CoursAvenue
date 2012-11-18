class Discipline < ActiveRecord::Base
  has_ancestry

  belongs_to :discipline

  attr_accessible :name

  validates :name, :presence   => true
  validates :name, :uniqueness => true

end
