class IndexableCard < ActiveRecord::Base
  acts_as_paranoid

  include AlgoliaSearch

  belongs_to :structure
  belongs_to :place
  belongs_to :planning
  belongs_to :course

  has_and_belongs_to_many :subjects

  attr_accessible :structure, :place, :planning, :course

  delegate :name, :price,                 to: :course,    prefix: true
  delegate :name, :comments_count, :slug, to: :structure, prefix: true
  delegate :place, :latitude, :longitude, to: :place,     prefix: true

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id

    add_attribute :name do
      self.course ? self.course_name : self.subject_name
    end

    add_attribute :price do
      self.course ? self.course_price : 0
    end

    add_attribute :structure_name do
      self.structure_name
    end

    add_attribute :reviews_count do
      self.structure_comments_count
    end

    add_attribute :type do
      'indexable_card'
    end

    add_attribute :structure_id do
      self.structure_id
    end

    add_attribute :course_id do
      self.course_id
    end

    add_attribute :structure_slug do
      self.structure_slug
    end

    add_attribute :root_subject do
      roots = course.subjects.map{ |s| s.root.slug }.uniq
      (roots.length == 1 ? roots.first : 'multi')
    end

    add_attribute :subjects do
      course.subjects.map(&:slug).uniq
    end

    geoloc(:place_latitude, :place_longitude)
  end
  # :nocov:

  # Create a card from a Planning
  #
  # @param planning the planning
  #
  # @return the new card.
  def self.create_from_planning(planning)
    attributes = {
      planning:  planning,
      structure: planning.structure,
      place:     planning.place,
      course:    planning.course
    }

    if (existing_cards = where(attributes)).any?
      return existing_cards.first
    end

    card = create(attributes)

    planning.subjects.each do |subject|
      card.subjects << subject
    end

    card
  end

  # Create a card from a Subject and a Place
  #
  # @param subject the subject
  # @param place the place
  #
  # @return the new card.
  def self.create_from_subject_and_place(subject, place)
    attributes = { place: place, structure: place.structure }
    existing_cards = where(attributes)

    if existing_cards.any? and existing_cards.flat_map(&:subjects).include?(subject)
      return existing_cards.first
    end

    card = create(attributes)
    card.subjects << subject

    card
  end

  # The subject name. This should only occur when the card has been created with a place and a
  # subject instead of a planning.
  #
  # @return String, the subject name.
  def subject_name
    subjects.first.name
  end
end
