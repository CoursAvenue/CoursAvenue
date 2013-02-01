class City < ActiveRecord::Base
  has_many :structures

  attr_accessible :name, :short_name

  validates :name, :short_name, uniqueness: true
end
