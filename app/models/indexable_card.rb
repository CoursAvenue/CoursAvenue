class IndexableCard < ActiveRecord::Base
  acts_as_paranoid

  include AlgoliaSearch

  belongs_to :structure
  belongs_to :place
  belongs_to :planning
  belongs_to :course

  has_and_belongs_to_many :subjects

  attr_accessible :structure, :place, :planning, :course

  delegate :name, :price, :type,                   to: :course,    prefix: true, allow_nil: true
  delegate :name, :comments_count, :slug,          to: :structure, prefix: true, allow_nil: true
  delegate :name, :latitude, :longitude, :address, to: :place,     prefix: true, allow_nil: true

  scope :with_plannings, -> { where.not(planning_id: nil) }

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id

    add_attribute :name do
      self.course_name or self.subject_name
    end

    add_attribute :price do
      self.course_price
    end

    attributes :structure_name

    add_attribute :comments_count do
      self.structure_comments_count
    end

    add_attribute :type do
      'indexable_card'
    end

    add_attribute :end_date do
      if planning and planning.end_date
        planning.end_date
      else
        100.years.from_now
      end
    end

    attribute :structure_id
    attribute :course_id
    attribute :course_name
    attribute :course_type
    attribute :structure_slug
    attribute :place_name
    attribute :place_address

    add_attribute :root_subject do
      roots = subjects.map { |s| s.root.slug }.uniq
      (roots.length == 1 ? roots.first : 'multi')
    end

    add_attribute :subjects do
      self.subjects.map do |subject|
        { name: subject.name, slug: subject.slug, slug_name: "#{subject.slug}:#{subject.name}" }
      end
    end

    add_attribute :has_free_trial do
      if self.course.present?
        self.course.prices.any?(&:free?)
      else
        false
      end
    end

    add_attribute :_geoloc do
      if self.place_latitude.present? and self.place_longitude.present?
        { lat: self.place_latitude, lng: self.place_longitude }
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

    add_attribute :structure_logo_url do
      structure.logo.url(:small_thumb_85) if structure.logo?
    end

    add_attribute :identity do
      [card_type, structure_id, place_id, course_id].compact.join(':')
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

    card = new(attributes)

    planning.subjects.each do |subject|
      card.subjects << subject
    end

    card.save

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
  # TODO: Improve this. The letter shouldn't have to be set here, but set on the frontend.
  # The representation of the information should be as general here are possible and leave the
  # actual presentation to the frontend.
  #
  # @return an array.
  def weekly_availability
    return [] if course.nil?

    availability = [
      { day: 'monday',    count: 0, letter: 'L' },
      { day: 'tuesday',   count: 0, letter: 'M' },
      { day: 'wednesday', count: 0, letter: 'M' },
      { day: 'thursday',  count: 0, letter: 'J' },
      { day: 'friday',    count: 0, letter: 'V' },
      { day: 'saturday',  count: 0, letter: 'S' },
      { day: 'sunday',    count: 0, letter: 'D' }
    ]

    course.plannings.each do |course|
      course_day = Date::DAYNAMES[course.week_day].downcase
      day_availability = availability.detect { |d| d[:day] == course_day }

      day_availability[:count] += 1
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

  private

  # The type of the card.
  #
  # @return a string.
  def card_type
    planning.present? ? 'planning_card' : 'subject_card'
  end
end
