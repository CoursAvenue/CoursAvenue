class Ratp::Line < ActiveRecord::Base
  LINE_TYPE = %w(metro rer tramway)

  include AlgoliaSearch
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :positions, -> { order(position: :asc) },
    class_name: 'Ratp::Position', foreign_key: 'ratp_line_id', dependent: :destroy

  has_many :stops, -> { order 'ratp_positions.position ASC' },
    through: :positions, class_name: 'Ratp::Stop'

  attr_accessible :name, :route_name, :number, :color, :line_type

  validates :name,       presence: true
  validates :route_name, presence: true

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attributesForFaceting [:slug]

    attribute :id
    attribute :slug
    attribute :name
    attribute :number
    attribute :route_name
    attribute :color
    attribute :line_type

    add_attribute :ratp_stops do
      self.stops.map(&:slug)
    end
  end
  # :nocov:

  def bis?
    name.include?('Bis')
  end

  def number_without_bis
    number.gsub(' Bis', '')
  end
end
