class Discipline < ActiveRecord::Base
  has_ancestry
  has_attached_file :image, :styles => { :wide=> "300x300#", :thumb => "100x100>" }

  has_and_belongs_to_many :courses

  attr_accessible :name, :image

  validates :name, :presence   => true
  validates :name, :uniqueness => true

end
