class IndexableCard < ActiveRecord::Base
  extend FriendlyId
  friendly_id :friendly_name, use: [:slugged, :finders]

  include AlgoliaSearch

  acts_as_paranoid

  belongs_to :structure
  belongs_to :place
  belongs_to :course

  has_many :plannings
  has_many :user_favorites, class_name: 'User::Favorite', dependent: :destroy

  has_and_belongs_to_many :subjects

  attr_accessible :structure, :place, :plannings, :course, :slug, :popularity

  delegate :name, :price, :type, :audiences, :levels, to: :course,    prefix: true, allow_nil: true
  delegate :name, :comments_count, :slug,             to: :structure, prefix: true, allow_nil: true
  delegate :name, :latitude, :longitude, :address,    to: :place,     prefix: true, allow_nil: true

  delegate :no_trial, to: :course, prefix: false, allow_nil: true

  scope :with_course, -> { where.not(course_id: nil) }
  scope :with_place,  -> { where.not(place_id: nil) }

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attributesToIndex ['course_name', 'unordered(subjects.name)', 'structure_name',
                       'unordered(audiences_fr)', 'unordered(levels_fr)',
                       'unordered(metro_stops_fr)', 'teaches_at_home', 'city_name',
                       'city_zip_code', 'unordered(planning_periods_fr)',
                       'place_name']
    ignorePlurals true
    removeWordsIfNoResults 'allOptional'

    attributesForFaceting %w(id subjects.name root_subject subjects.slug planning_periods
                             structure_slug audiences subjects.slug_name levels card_type
                             metro_stops metro_lines has_course)

    add_slave 'IndexableCard_by_popularity_desc', per_environment: true do
      customRanking ['desc(popularity)']
      # Default ranking
      ranking ['typo', 'geo', 'words', 'proximity', 'attribute', 'exact', 'custom']
      attributesToIndex ['course_name', 'unordered(subjects.name)', 'structure_name',
                         'unordered(audiences_fr)', 'unordered(levels_fr)',
                         'unordered(metro_stops_fr)', 'teaches_at_home', 'city_name',
                         'city_zip_code', 'unordered(planning_periods_fr)',
                         'place_name']
      ignorePlurals true
      removeWordsIfNoResults 'allOptional'

      attributesForFaceting %w(id subjects.name root_subject subjects.slug planning_periods
                               structure_slug audiences subjects.slug_name levels card_type
                               metro_stops metro_lines has_course)

    end

    attribute :id, :slug

    add_attribute :teaches_at_home do
      if course and course.try(:teaches_at_home?)
        'À domicile'
      end
    end

    add_attribute :city_slug do
      self.place.try(:city).try(:slug)
    end

    add_attribute :city_name do
      self.place.try(:city).try(:name)
    end

    add_attribute :city_zip_code do
      self.place.try(:city).try(:zip_code)
    end

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
      if course and course.is_training? and plannings and (end_dates = plannings.map(&:end_date)).any?
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

    add_attribute :no_trial do
      course.no_trial if course
    end

    add_attribute :root_subject do
      roots = subjects.map { |s| s.root.slug }.uniq
      roots.first
    end

    add_attribute :subjects do
      # We load child and mid subjects
      _all_subjects = []
      self.subjects.each do |subject|
        _all_subjects << subject
        _all_subjects << subject.parent if subject.depth == 2
      end
      _all_subjects.uniq.map do |subject|
        {
          name: subject.name,
          slug: subject.slug,
          slug_name: "#{subject.slug}:#{subject.name}",
          root_slug: subject.root.slug
        }
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
      if course and course.media
        course.media.image.url(:search_thumbnail)
      elsif structure.medias.any?
        image = structure.medias.cover_first.images_first.first.image
        image.url(:search_thumbnail)
      end
    end

    add_attribute :popularity do
      self.popularity || compute_popularity
    end

    add_attribute :has_course do
      self.course.present?
    end

    add_attribute :structure_logo_url do
      structure.logo.url(:small_thumb_85) if structure.logo?
    end

    add_attribute :structure_logo_large_url do
      structure.logo.url(:small_thumb_85) if structure.logo?
    end

    attribute :identity
    attribute :planning_periods
    attribute :planning_periods_fr

    add_attribute :audiences do
      if self.course
        self.course_audiences.map(&:name) if self.course_audiences
      elsif
        [Audience::ADULT.name]
      end
    end

    add_attribute :audiences_fr do
      if self.course
        self.course_audiences.map{|a| I18n.t(a.name) } if self.course_audiences
      elsif
        [I18n.t(Audience::ADULT.name)]
      end
    end

    add_attribute :levels do
      if self.course
        self.course_levels.map(&:name) if self.course_levels
      elsif
        [Level::ALL.name, Level::BEGINNER.name, Level::INTERMEDIATE.name]
      end
    end

    add_attribute :levels_fr do
      if self.course
        self.course_levels.map{|l| I18n.t(l.name) } if self.course_levels
      else
        [I18n.t(Level::ALL.name), I18n.t(Level::BEGINNER.name), I18n.t(Level::INTERMEDIATE.name)]
      end
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

    add_attribute :metro_stops do
      place.nearby_metro_stops.map(&:slug) if place.present?
    end

    add_attribute :metro_stops_fr do
      place.nearby_metro_stops.map(&:name) if place.present?
    end

    add_attribute :metro_lines do
      place.nearby_metro_stops.flat_map(&:lines).uniq.map(&:slug) if place.present?
    end
  end
  # :nocov:

  def self.place_for_card(course)
    if course.teaches_at_home? and course.try(:home_place)
      place = course.home_place
    else
      place = course.try(:place)
    end
  end

  # Create cards from a Course
  #
  # @param course the course
  #
  # @return the new cards.
  def self.create_from_course(course)
    if (existing_cards = where(course: course)).any?
      return existing_cards
    end

    course_subjects = course.subjects

    cards = course.plannings.group_by(&:place).map do |place, plannings|
      place = IndexableCard.place_for_card(course) if place.nil?
      next if place.nil?
      attributes = {
        structure: course.structure,
        course:    course,
        place:     place,
      }

      card = new(attributes)
      card.plannings = plannings

      card.subjects = course_subjects.uniq.compact
      card.save

      card
    end

    cards
  end

  # Create cards from a Course
  #
  # @param course the course
  #
  # @return the new cards.
  def self.update_from_course(course)
    existing_cards = where(course: course)

    course_subjects = course.subjects
    cards = course.plannings.group_by(&:place).map do |place, plannings|
      place = IndexableCard.place_for_card(course) if place.nil?
      next if place.nil?
      attributes = {
        structure: course.structure,
        course:    course,
        place:     place,
      }
      card = existing_cards.detect{ |c| c.place == place } || new(attributes)
      card.plannings = plannings

      card.subjects = course_subjects.uniq.compact
      card.save

      existing_cards -= [card]
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
  def self.create_from_place(place)
    attributes = { place: place, structure: place.structure }
    existing_cards = where(attributes)

    if existing_cards.any?
      return existing_cards.first
    end

    card = create(attributes)
    card.subjects = place.subjects
    card.save

    card
  end

  def name
    course_name || subject_name
  end

  # The subject name. This should only occur when the card has been created with a place and a
  # subject instead of a course.
  #
  # @return String, the subject name.
  def subject_name
    subjects.any? ? subjects.first.name : nil
  end

  # Returns the availability of the course during the week.
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
      next if planning.week_day.nil? or Date::DAYNAMES[planning.week_day].nil?
      course_day = Date::DAYNAMES[planning.week_day].downcase
      day_availability = availability.detect { |d| d[:day] == course_day }

      day_availability[:count] += 1
      day_availability[:start_times] << I18n.l(planning.start_time, format: :short) if planning.start_time
    end

    availability
  end

  # Returns the periods during the courses take place in the following format:
  # `DAY-PERIOD`. Example: `monday-0` for a course taking place at 8AM on a monday.
  #
  # @return an array of string.
  def planning_periods
    return [] if plannings.empty? or course.nil?

    periods = []
    course.plannings.each do |planning|
      next if planning.week_day.nil? or Date::DAYNAMES[planning.week_day].nil?
      course_day = Date::DAYNAMES[planning.week_day].downcase
      periods += planning.periods.map { |period| "#{course_day}-#{period}" }
    end

    periods.uniq
  end

  # @return an array of string.
  def planning_periods_fr
    return [] if plannings.empty? or course.nil?

    periods = []
    course.plannings.each do |planning|
      next if planning.week_day.nil? or Date::DAYNAMES[planning.week_day].nil?
      course_day = I18n.t('date.day_names')[planning.week_day]
      periods += planning.periods.map do |period|
        period = I18n.t("date.periods.#{period}")
        "#{course_day} #{period}"
      end
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

  SEARCH_SCORE_COEF = {
    free_trial:      4,
    plannings:       3,
    prices:          2,
    promotions:      4  ,
    medias:          3,
    course_media:    10,
    teaches_at_home: -10,
    week_days:       3,
  }

  # @return Integer
  def compute_popularity
    score_to_add = 0
    score_to_add += plannings.map(&:week_day).uniq.length * SEARCH_SCORE_COEF[:week_days]
    score_to_add += SEARCH_SCORE_COEF[:teaches_at_home] if course and course.is_private? and course.teaches_at_home
    score_to_add += SEARCH_SCORE_COEF[:plannings] if plannings.count > 0
    score_to_add += SEARCH_SCORE_COEF[:prices]    if course and course.price_group_prices.count > 0
    ## Promotions
    if course and course.price_group_prices.select{ |p| p.promo_amount.present? }.any?
      score_to_add += SEARCH_SCORE_COEF[:promotions]
    end

    if course and course.has_free_trial_lesson?
      score_to_add += SEARCH_SCORE_COEF[:free_trial]
    end

    ## Medias
    if course and course.media
      score_to_add += SEARCH_SCORE_COEF[:course_media]
    end
    if structure.medias.count > 0
      score_to_add += SEARCH_SCORE_COEF[:medias]
    end

    score = structure.search_score.to_i + score_to_add
    self.update_column :popularity, score
    return score
  end

  def identity
    [card_type, structure_id, place_id, course_id].compact.join(':')
  end

  def friendly_name
    [
      [:course_name, :place_name],
      [:structure_name, :subject_name, :place_name]
    ]
  end
end
