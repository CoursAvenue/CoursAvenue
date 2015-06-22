class IndexableCard < ActiveRecord::Base
  acts_as_paranoid

  include AlgoliaSearch

  belongs_to :structure
  belongs_to :place
  belongs_to :course

  has_many :plannings

  has_and_belongs_to_many :subjects

  attr_accessible :structure, :place, :plannings, :course

  delegate :name, :price, :type, :audiences, :levels, to: :course,    prefix: true, allow_nil: true
  delegate :name, :comments_count, :slug,             to: :structure, prefix: true, allow_nil: true
  delegate :name, :latitude, :longitude, :address,    to: :place,     prefix: true, allow_nil: true

  scope :with_course, -> { where.not(course_id: nil) }

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
      if plannings and (end_dates = plannings.map(&:end_date)).any?
        end_dates.max.to_time.to_i
      else
        100.years.from_now.to_time.to_i
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

    attribute :identity
    attribute :planning_periods

    attribute :registration_count do
      (course ? course.participation_requests.count : 0)
    end

    add_attribute :audiences do
      self.course_audiences.map(&:name) if self.course_audiences
    end

    add_attribute :levels do
      self.course_levels.map(&:name) if self.course_levels
    end

    attribute :card_type

    add_attribute :trainings do
      if course and course.is_training?
        course.plannings('start_date ASC, start_time ASC').map do |p|
          DateTime.new(p.start_date.year, p.start_date.month, p.start_date.day,
                       p.start_time.hour, p.start_time.min, p.start_time.sec).to_i
        end
      end
    end

    add_attribute :trainings_end_date do
      if course and course.is_training?
        course.plannings('end_date ASC, end_time ASC').map do |p|
          DateTime.new(p.end_date.year, p.end_date.month, p.end_date.day,
                       p.end_time.hour, p.end_time.min, p.end_time.sec).to_i
        end
      end
    end

  end
  # :nocov:

  # Create cards from a Course
  # TODO: Refactor this so we only create one card instead of several.
  #
  # @param course the course
  #
  # @return the new cards.
  def self.create_from_course(course)
    if (existing_cards = where(course: course)).any?
      return existing_cards
    end

    cards = course.plannings.group_by(&:place).map do |place, plannings|
      attributes = {
        structure: course.structure,
        course:    course,
        place:     place,
      }

      card = new(attributes)
      card.plannings = plannings

      plannings.flat_map(&:subjects).uniq.compact.each do |subject|
        card.subjects << subject
      end
      card.save

      card
    end

    cards
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
  # subject instead of a course.
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
      { day: 'monday',    count: 0, start_times: [] },
      { day: 'tuesday',   count: 0, start_times: [] },
      { day: 'wednesday', count: 0, start_times: [] },
      { day: 'thursday',  count: 0, start_times: [] },
      { day: 'friday',    count: 0, start_times: [] },
      { day: 'saturday',  count: 0, start_times: [] },
      { day: 'sunday',    count: 0, start_times: [] }
    ]

    course.plannings.order('start_time ASC, end_time ASC').each do |planning|
      course_day = Date::DAYNAMES[planning.week_day].downcase
      day_availability = availability.detect { |d| d[:day] == course_day }

      day_availability[:count] += 1
      day_availability[:start_times] << I18n.l(planning.start_time, format: :short)
    end

    availability
  end

  # Returns the periods during the courses take place in the following format:
  # `DAY-PERIOD`. Example: `monday-0` for a course taking place at 8AM on a monday.
  #
  # @return an array of string.
  def planning_periods
    return [] if plannings.empty?

    periods = []
    course.plannings.each do |planning|
      course_day = Date::DAYNAMES[planning.week_day].downcase
      periods += planning.periods.map { |period| "#{course_day}-#{period}" }
    end

    periods.uniq
  end

  # The starting price of the card.
  #
  # @return the lowest price for this course.
  def starting_price
    return 0.0 if course.nil?

    price = course.prices.order('amount ASC').first
    price.present? ? price.amount.to_f : 0.0
  end

  # The type of the card. Used for the identity and the search context.
  #
  # @return a string.
  def card_type
    if course.present? and course_type == 'Course::Training'
      'training'
    else
      'course'
    end
  end

  private

  def identity
    [card_type, structure_id, place_id, course_id].compact.join(':')
  end
end
