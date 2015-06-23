class Metro::Stop < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :lines, class_name: 'Metro::Line'

  validates :name,      presence: true
  validates :latitude,  presence: true
  validates :longitude, presence: true
end
