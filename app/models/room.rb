class Room < ActiveRecord::Base
  belongs_to :place
  attr_accessible :name, :surface

  validates :name, uniqueness: {scope: 'place_id'}
  validates :name, presence: true
end
