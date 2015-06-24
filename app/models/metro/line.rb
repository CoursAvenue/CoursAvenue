class Metro::Line < ActiveRecord::Base
  include AlgoliaSearch
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_and_belongs_to_many :stops, class_name: 'Metro::Stop'

  attr_accessible :name, :line_number

  validates :name, presence: true

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id
    attribute :slug
    attribute :name

    add_attribute :metro_stops do
      self.stops.map(&:slug)
    end
  end
  # :nocov:
end
