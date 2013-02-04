class Subject < ActiveRecord::Base
  has_ancestry
  has_attached_file :image, :styles => { wide: "600x375#", thumb: "200x200#" }

  has_and_belongs_to_many :courses

  attr_accessible :name, :short_name, :image, :info

  validates :name, :presence   => true
  validates :name, :uniqueness => true

end
