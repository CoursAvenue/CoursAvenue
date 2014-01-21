# encoding: utf-8
class Planning < ActiveRecord::Base

  TIME_SLOTS = {
    morning: {
      name:       'planning.timeslots.morning',
      start_time: 0,
      end_time:   12,
    },
    noon: {
      name:       'planning.timeslots.noon',
      start_time: 12,
      end_time:   14
    },
    afternoon: {
      name:       'planning.timeslots.afternoon',
      start_time: 14,
      end_time:   18
    },
    evening: {
      name:       'planning.timeslots.evening',
      start_time: 18,
      end_time:   24
    }
  }
  acts_as_paranoid

  include PlanningsHelper

  belongs_to :course, touch: true
  has_many   :prices, through: :course
  belongs_to :teacher
  belongs_to :place
  belongs_to :structure

  has_many :reservations,         as: :reservable

  has_many :participations
  has_many :users, through: :participations

  before_validation :set_start_date
  before_validation :set_end_date
  before_validation :set_end_time
  before_validation :update_duration
  before_validation :set_audience_if_empty
  before_validation :set_level_if_empty


  after_initialize :default_values
  before_save :set_structure_if_blank

  # validates :teacher, presence: true
  validates :place, :audience_ids, :level_ids, presence: true
  validate  :presence_of_start_date
  validate  :update_start_and_end_date
  validate  :end_date_in_future
  validates :min_age_for_kid, numericality: { less_than: 18 }, allow_nil: true
  validates :max_age_for_kid, numericality: { less_than: 19 }, allow_nil: true

  validate do |planning|
    if (max_age_for_kid.present? or min_age_for_kid.present?) and min_age_for_kid.to_i >= max_age_for_kid.to_i
      planning.errors.add(:max_age_for_kid, "L'age maximum ne peut être inférieur à l'age minimum")
    end
  end


  attr_accessible :duration, # In minutes
                  :end_date,
                  :start_date,
                  :start_time, # Format: Time.parse("2000-01-01 #{value} UTC")
                  :end_time,   # Format: Time.parse("2000-01-01 #{value} UTC")
                  :week_day, # 0: Dimanche, 1: Lundi, as per I18n.t('date.day_names')
                  :class_during_holidays,
                  :nb_participants_max,
                  :nb_place_available,
                  :promotion,
                  :info,
                  :min_age_for_kid,
                  :max_age_for_kid,
                  :teacher,
                  :teacher_id,
                  :level_ids,
                  :audience_ids,
                  :place_id

  scope :future,         -> { where("plannings.end_date > '#{Date.today}'") }
  scope :past,           -> { where("plannings.end_date <= '#{Date.today}'") }
  scope :ordered_by_day, -> { order('week_day=0, week_day ASC') }

  # ------------------------------------------------------------------------------------ Search attributes
  searchable do

    boolean :active_course do
      self.course.active?
    end

    # ----------------------- For grouping
    string :course_id_str do
      course.structure_id.to_s
    end

    string :structure_id_str do
      course.structure_id.to_s
    end

    string :place_id_str do
      place_id.to_s
    end

    integer :structure_id do
      course.structure_id.to_s
    end

    # ----------------------- Fulltext search
    text :name, boost: 5 do
      self.structure.name
    end

    text :course_name do
      self.course.name
    end

    text :course_subjects_name do
      self.course.subjects.uniq.map(&:name)
    end

    text :course_names do
      self.structure.courses.map(&:name)
    end

    text :course_description do
      self.course.description
    end

    # text :structure_description do
    #   self.structure.description
    # end

    text :subjects, boost: 5 do
      subject_array = []
      self.structure.subjects.uniq.each do |subject|
        subject_array << subject
        subject_array << subject.root        if subject.root
      end
      subject_array.uniq.map(&:name)
    end

    integer :subject_ids, multiple: true do
      subject_ids = []
      self.structure.subjects.uniq.each do |subject|
        subject_ids << subject.id
        subject_ids << subject.root.id if subject.root
      end
      subject_ids.compact.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      self.structure.subjects.uniq.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.root.slug if subject.root
      end
      subject_slugs.uniq
    end

    integer :audience_ids, multiple: true do
      self.audience_ids
    end

    integer :level_ids, multiple: true do
      self.level_ids
    end

    integer :week_days, multiple: true do
      self.week_days
    end

    time :start_time
    time :end_time

    integer :start_hour do
      start_time.hour if start_time
    end

    integer :end_hour do
      end_time.hour if end_time
    end

    time :start_date
    time :end_date

    string :price_types, multiple: true do
      price_types = []
      Price::TYPES.each do |name|
        price_types << name if price_amount_for_scope(name).any?
      end
      price_types
    end

    Price::TYPES.each do |name|
      integer "#{name}_min_price".to_sym do
        self.min_price_amount_for(name)
      end
      integer "#{name}_max_price".to_sym do
        self.max_price_amount_for(name)
      end
    end

    integer :min_age_for_kid
    integer :max_age_for_kid

    string :course_type do
      self.course.underscore_name
    end

    boolean :has_trial_course do
      self.course.prices.trials.any?
    end

    integer :trial_course_amount do
      if self.course.prices.trials.any?
        self.course.prices.trials.map(&:amount).min.to_i
      end
    end

    string :discounts, multiple: true do
      self.course.prices.discounts.collect{ |discount| discount.libelle.split('.').last }.uniq
    end

    integer :funding_type_ids, multiple: true do
      self.structure.funding_type_ids
    end

    string :structure_type do
      self.structure.structure_type.split('.').last if self.structure.structure_type
    end

    integer :nb_comments do
      self.structure.comments_count
    end

    boolean :has_comment do
      self.structure.comments_count > 0
    end

    boolean :has_logo do
      self.structure.logo?
    end

    latlon :location, multiple: true do
      Sunspot::Util::Coordinates.new(place.location.latitude, place.location.longitude) if place
    end
  end

  # ---------------------------- Simulating Audience and Levels
  def audience_ids= _audiences
    if _audiences.is_a? Array
      write_attribute :audience_ids, _audiences.reject{|level| level.blank?}.join(',')
    else
      write_attribute :audience_ids, _audiences
    end
  end

  def audiences= _audiences
    if _audiences.is_a? Array
      write_attribute :audience_ids, _audiences.map(&:id).join(',')
    elsif _audiences.is_a? Audience
      write_attribute :audience_ids, _audiences.id.to_s
    end
  end

  def audiences
    return [] unless audience_ids.present?
    self.audience_ids.map{ |audience_id| Audience.find(audience_id) }
  end

  def audience_ids
    return [] unless read_attribute(:audience_ids)
    read_attribute(:audience_ids).split(',').map(&:to_i) if read_attribute(:audience_ids)
  end

  def level_ids= _levels
    if _levels.is_a? Array
      write_attribute :level_ids, _levels.reject{|level| level.blank?}.join(',')
    else
      write_attribute :level_ids, _levels
    end
  end

  def levels= _levels
    if _levels.is_a? Array
      write_attribute :level_ids, _levels.map(&:id).join(',')
    elsif _levels.is_a? level
      write_attribute :level_ids, _levels.id.to_s
    end
  end

  def level_ids
    return [] unless read_attribute(:level_ids)
    read_attribute(:level_ids).split(',').map(&:to_i) if read_attribute(:level_ids)
  end

  def levels
    return [] unless level_ids.present?
    self.level_ids.map{ |level_id| Level.find(level_id) }
  end
  # ---------------------------- End

  # 0: Dimanche, 1: Lundi, as per I18n.t('date.day_names')
  def week_day
    if read_attribute(:week_day)
      read_attribute(:week_day)
    elsif start_date
      start_date.wday
    else
      nil
    end
  end

  def to_s
    case self.course.type
    when 'Course::Lesson'
      "#{week_day_for self} à #{I18n.l(self.start_time, format: :short)}"
    when 'Course::Workshop'
      "#{I18n.l(self.start_date, format: :semi_long).capitalize} à #{I18n.l(self.start_time, format: :short)}"
    when 'Course::Training'
      "#{I18n.l(self.start_date, format: :semi_long).capitalize} à #{I18n.l(self.start_time, format: :short)}"
    end
  end

  def length
    return (end_date - start_date).to_i + 1
  end

  def duplicate
    duplicate_planning = self.dup
  end

  def for_kid?
    audiences.include? Audience::KID
  end

  def time_slot_name
    start_hour = self.start_time.hour
    if start_hour < 12
      return 'morning'
    elsif start_hour < 14
      return 'noon'
    elsif start_hour < 18
      return 'afternoon'
    else
      return 'evening'
    end
  end

  def min_price_amount_for(type)
    price = price_amount_for_scope(type).order('amount ASC').first
    return 0 unless price
    price.amount.to_i
  end

  def max_price_amount_for(type)
    price = price_amount_for_scope(type).order('amount DESC').first
    return 0 unless price
    price.amount.to_i
  end

  def week_days
    if self.course.is_lesson?
      [self.week_day]
    else
      if self.start_date and self.end_date
        (self.start_date..self.end_date).to_a.map(&:wday).uniq
      elsif self.start_date
        [self.start_date.wday]
      end
    end
  end

  def nb_participants_max
    read_attribute(:nb_participants_max) or self.course.nb_participants_max
  end

  # Participations that can be counted and are not exceeded the quota
  def possible_participations
    self.participations[0..(self.nb_participants_max - 1)]
  end

  def waiting_list
    self.participations - self.possible_participations
  end

  private

  # Return the scoped price for a given type.
  # Used in search
  def price_amount_for_scope(type)
    case type
    when 'per_course'
      self.course.prices.book_tickets.individual
    when 'book_ticket'
      self.course.prices.book_tickets.multiple_only
    when 'annual_subscription'
      self.course.prices.subscriptions.annual
    when 'semestrial_subscription'
      self.course.prices.subscriptions.semestrial
    when 'trimestrial_subscription'
      self.course.prices.subscriptions.trimestrial
    when 'monthly_subscription'
      self.course.prices.subscriptions.monthly
    when 'any_per_course'
      self.course.prices.book_tickets
    when 'all_subscriptions'
      self.course.prices.subscriptions
    end
  end

  def set_structure_if_blank
    self.structure = self.course.structure if self.course
  end

  def default_values
    if self.new_record?
      self.audiences = [Audience::ADULT] if self.audiences.empty?
      self.levels    = [Level::ALL]      if self.levels.empty?
    end
  end

  # Update duration column regarding start and end time
  def update_duration
    if self.start_time and self.end_time and duration.blank?
      time_at = Time.zone.at(self.end_time - self.start_time)
      self.duration = (time_at.hour * 60) + time_at.min
    end
  end

  # Set end time column regarding start time and duration
  def set_end_time
    unless self.end_time.present?
      if self.start_time and self.duration
        self.end_time = self.start_time + self.duration.minutes
      end
    end
  end

  # Set default start date
  def set_start_date
    if self.start_date.nil? and self.course.is_lesson?
      self.start_date = self.course.start_date || Date.yesterday
    end
  end

  # Set end date
  def set_end_date
    unless end_date.present?
      if course.is_lesson?
        self.end_date = self.course.end_date
      else
        self.end_date = self.start_date
      end
    end
  end

  # Validations
  def presence_of_start_date
    if course.is_workshop? or course.is_training? or course.is_open?
      unless start_date.present?
        errors.add(:start_date, :blank)
      end
    end
  end

  def update_start_and_end_date
    if course.is_lesson?
      self.start_date = course.start_date if self.start_date != course.start_date
      self.end_date   = course.end_date   if self.end_date != course.end_date
    end
  end

  def end_date_in_future
    if end_date and end_date < Date.today
      errors.add(:end_date, 'Le cours ne peut pas être dans le passé.')
    end
  end

  def set_audience_if_empty
    self.audiences = [Audience::ADULT] if self.audiences.empty?
  end

  def set_level_if_empty
    self.levels    = [Level::ALL]      if self.levels.empty?
  end
end
