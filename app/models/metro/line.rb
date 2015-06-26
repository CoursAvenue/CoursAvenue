class Metro::Line < ActiveRecord::Base
  include AlgoliaSearch
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :positions, -> { order(position: :asc) },
    class_name: 'Metro::Position', foreign_key: 'metro_line_id'

  has_many :stops, -> { order 'metro_positions.position ASC' },
    through: :positions, class_name: 'Metro::Stop'

  attr_accessible :name, :route_name, :number, :color

  validates :name,       presence: true
  validates :route_name, presence: true

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id
    attribute :slug
    attribute :name
    attribute :number
    attribute :route_name

    add_attribute :metro_stops do
      self.stops.map(&:slug)
    end
  end
  # :nocov:
end
