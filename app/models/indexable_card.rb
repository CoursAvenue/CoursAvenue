class IndexableCard < ActiveRecord::Base
  acts_as_paranoid

  include AlgoliaSearch

  belongs_to :structure
  belongs_to :place
  belongs_to :planning
  belongs_to :course

  has_and_belongs_to_many :subjects

  attr_accessible :structure, :place, :planning, :course

  delegate :name, :price, :type,          to: :course,    prefix: true, allow_nil: true
  delegate :name, :comments_count, :slug, to: :structure, prefix: true, allow_nil: true
  delegate :name, :latitude, :longitude,  to: :place,     prefix: true, allow_nil: true

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id

    add_attribute :name do
      self.course ? self.course_name : self.subject_name
    end

    add_attribute :price do
      self.course_price
    end

    attributes :structure_name

    add_attribute :reviews_count do
      self.structure_comments_count
    end

    add_attribute :type do
      'indexable_card'
    end

    attribute :structure_id
    attribute :course_id
    attribute :course_name
    attribute :course_type
    attribute :structure_slug
    attribute :place_name

    add_attribute :root_subject do
      roots = subjects.map { |s| s.root.slug }.uniq
      (roots.length == 1 ? roots.first : 'multi')
    end

    add_attribute :subjects do
      self.subjects.map(&:slug).uniq
    end

    add_attribute :has_free_trial do
      if self.course.present?
        self.course.prices.any?(&:free?)
      else
        false
      end
    end

    add_attribute :_geoloc do
      if self.place.present?
        { lat: self.place.latitude, lng: self.place.longitude }
      end
    end

    attribute :weekly_availability
    attribute :starting_price

    add_attribute :header_image do
      if structure.medias.any?
        image = structure.medias.cover_first.images_first.first.image
        image.url(:search_thumbnail)
      end
    end

    add_attribute :is_sleeping do
      self.structure.is_sleeping?
    end
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
    subjects.any? ? subjects.first.name : nil
  end

  # Returns the availability of the course during the week.
  #
  # @return an array.
  def weekly_availability
    return [] if course.nil?

    availability = {
      sunday:    0,
      monday:    0,
      tuesday:   0,
      wednesday: 0,
      thursday:  0,
      friday:    0,
      saturday:  0,
    }

    course.plannings.each do |course|
      day = Date::DAYNAMES[course.week_day].downcase.to_sym
      availability[day] += 1
    end

    availability
  end

  # The starting price of the card.
  #
  # @return the lowest price for this course.
  def starting_price
    return 0.0 if course.nil?

    price = course.prices.order('amount ASC').first
    price.present? ? price.amount.to_f : 0.0
  end
end
