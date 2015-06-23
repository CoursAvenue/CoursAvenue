class Metro::Line < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_and_belongs_to_many :stops, class_name: 'Metro::Stop'

  validates :name, presence: true
end
