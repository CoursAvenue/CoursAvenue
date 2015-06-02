class IndexableCard < ActiveRecord::Base
  include AlgoliaSearch

  belongs_to :structure
  belongs_to :place
  belongs_to :planning
  belongs_to :course

  attr_accessible :structure, :subject, :place, :planning, :course

  delegate :name, :price,          to: :course,    prefix: true
  delegate :name, :comments_count, to: :structure, prefix: true

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    add_attribute :name do
      self.course_name || self.subject_name
    end

    add_attribute :price do
      self.course_price
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

    geoloc(self.place.latitude, self.place.longitude)
  end
  # :nocov:

  # Create a card from a Planning
  #
  # @param planning the planning
  #
  # @return the new card.
  def self.create_from_planning(planning)
    create(planning:  planning,
           structure: planning.structure,
           place:     planning.place,
           course:    planning.course)
  end

  # Create a card from a Subject and a Place
  #
  # @param subject the subject
  # @param place the place
  #
  # @return the new card.
  def self.create_from_subject_and_place(subject, place)
    create(
      # subject:   subject,
      place:     place,
      structure: place.structure)
  end

  private

  # The subject name. This should only occur when the card has been created with a place and a
  # subject instead of a planning.
  #
  # @return String, the subject name.
  def subject_name
    subjects.first.name
  end
end
