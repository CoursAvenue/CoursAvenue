class Ratp::Stop < ActiveRecord::Base
  include AlgoliaSearch
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  reverse_geocoded_by :latitude, :longitude

  has_many :positions, -> { order(position: :asc) },
    class_name: 'Ratp::Position', foreign_key: 'ratp_stop_id', dependent: :destroy

  has_many :lines, -> { order 'ratp_lines.number ASC' },
    through: :positions, class_name: 'Ratp::Line'

  attr_accessible :name, :description, :latitude, :longitude

  validates :name,      presence: true
  validates :latitude,  presence: true
  validates :longitude, presence: true

  # TODO: Enable indexing when it will be needed.
  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attributesForFaceting ['metro_lines.line', 'slug']

    attribute :id
    attribute :slug
    attribute :name
    attribute :description

    add_attribute :_geoloc do
      { lat: self.latitude, lng: self.longitude }
    end

    add_attribute :metro_lines do
      self.positions.includes(:line).map do |p|
        { line: p.line.slug, position: p.position }
      end
    end
  end
  # :nocov:

end
