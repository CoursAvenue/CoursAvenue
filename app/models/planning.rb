# encoding: utf-8
class Planning < ActiveRecord::Base
  acts_as_paranoid
  include AlgoliaSearch
  # extend ActiveHashHelper
  include Concerns::ActiveHashHelper

  include PlanningsHelper
  include Concerns::HasAudiencesAndLevels

  TIME_SLOTS = {
    morning: {
      name:       'planning.timeslots.morning',
      short_name: 'morning',
      start_time: 0,
      end_time:   12,
    },
    noon: {
      name:       'planning.timeslots.noon',
      short_name: 'noon',
      start_time: 12,
      end_time:   14
    },
    afternoon: {
      name:       'planning.timeslots.afternoon',
      short_name: 'afternoon',
      start_time: 14,
      end_time:   18
    },
    evening: {
      name:       'planning.timeslots.evening',
      short_name: 'evening',
      start_time: 18,
      end_time:   24
    }
  }

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :course    , touch: true
  belongs_to :teacher   , touch: true
  belongs_to :place     , touch: true
  belongs_to :structure

  has_many :prices,         through: :course
  has_many :subjects,       through: :course
  has_many :reservations,   as: :reservable

  belongs_to :indexable_card

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_initialize :default_values

  before_validation :set_start_date
  before_validation :set_end_date
  before_validation :set_end_time
  before_validation :update_duration

  before_save :set_structure_if_blank

  after_save    :update_structure_meta_datas
  after_save    :update_indexable_cards

  before_destroy :destroy_indexable_cards
  before_destroy :update_indexable_cards

  # before_destroy :remove_from_jobs

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validate  :presence_of_place
  validate  :presence_of_start_date
  validate  :end_date_in_future

  attr_accessible :duration, # In minutes
                  :end_date, :start_date,
                  :start_time, # Format: Time.parse("2000-01-01 #{value} UTC")
                  :end_time,   # Format: Time.parse("2000-01-01 #{value} UTC")
                  :week_day, # 0: Dimanche, 1: Lundi, as per I18n.t('date.day_names')
                  :class_during_holidays,
                  :promotion, :info,
                  :min_age_for_kid, :max_age_for_kid, :teacher, :teacher_id, :level_ids, :audience_ids, :place_id, :is_in_foreign_country,
                  :visible # True by default, will be false only for plannings of
                           # private courses that are on demand

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  # Cannot be used directly like Planning.trainings_future because it will need to join with `:course`
  # It is aimed to be used like @structure.plannings.trainings_future because the `plannings` relation
  # is through `:courses` which make the join
  scope :trainings_future,  -> { where( Planning.arel_table[:end_date].gt(Date.today)
                                  .and(Course.arel_table[:type].eq('Course::Training')) ) }
  scope :future,            -> { where( arel_table[:end_date].gteq(Date.today).or(
                                        arel_table[:end_date].eq(nil)) ) }
  scope :past,              -> { where( arel_table[:end_date].lteq(Date.today) ) }
  scope :ordered_by_day,    -> { order('week_day=0, week_day ASC, start_time ASC, start_date ASC') }
  scope :visible,           -> { where(visible: true) }

  ######################################################################
  # Solr                                                               #
  ######################################################################
  # :nocov:
  searchable do
    integer :search_score do
      self.course.structure.compute_search_score
    end

    boolean :visible

    boolean :is_open_for_trial do
      course.is_open_for_trial
    end

    boolean :is_published do
      self.course.is_published?
    end

    boolean :active_structure do
      self.course.structure.active?
    end

    # ----------------------- For grouping
    string :structure_id_str do
      self.course.structure_id.to_s
    end

    string :place_id_str do
      if self.place_id
        self.place_id.to_s
      elsif self.course.place_id
        self.course.place_id.to_s
      end
    end

    integer :structure_id do
      self.course.structure_id.to_s
    end

    # ----------------------- Fulltext search
    # ----------------------- Course specific info
    text :course_name do
      self.course.name
    end

    text :course_subjects_name do
      self.course.subjects.uniq.map(&:name)
    end

    text :course_description do
      self.course.description
    end

    text :name, boost: 5 do
      self.course.structure.name
    end

    integer :subject_ids, multiple: true do
      subject_ids = []
      self.course.subjects.uniq.each do |subject|
        subject_ids << subject.id
        subject_ids << subject.root.id if subject.root
      end
      subject_ids.compact.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      self.course.subjects.uniq.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.parent.slug if subject.parent
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
      self.week_days.compact if self.week_days
    end

    time :start_time
    time :end_time

    integer :start_hour do
      start_time.hour if start_time
    end

    integer :end_hour do
      end_time.hour if end_time
    end

    time :start_date do
      self.start_date || self.course.start_date
    end

    time :end_date do
      if self.course.is_training?
        self.end_date
      else # Because regular courses doesn't have start and end_date
        Date.today + 100.year
      end
    end

    string :price_types, multiple: true do
      price_types = []
      Price::TYPES.each do |name|
        price_types << name if price_amount_for_scope(name).any?
      end
      price_types
    end

    integer :training_min_price do
      if self.course.is_training?
        price = self.course.prices.book_tickets.order('amount ASC').first
        if price
          price.amount.to_i
        else
          0
        end
      else
        -1
      end
    end

    integer :first_course_min_price do
      price = self.course.prices.book_ticket_or_trials.order('amount ASC').first
      if price
        price.amount.to_i
      else
        0
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
      self.course.structure.funding_type_ids
    end

    string :structure_type do
      self.course.structure.structure_type.split('.').last if self.course.structure.structure_type
    end

    integer :nb_comments do
      self.course.structure.comments_count
    end

    boolean :has_comment do
      self.course.structure.comments_count > 0
    end

    boolean :has_logo do
      self.course.structure.logo?
    end

    latlon :location, multiple: true do
      structure = self.structure || self.course.structure
      if place
        Sunspot::Util::Coordinates.new(place.latitude, place.longitude)
      else # Happens when the planning is out of France for example.
        Sunspot::Util::Coordinates.new(structure.latitude, structure.longitude)
      end
    end
  end
  # :nocov:

  handle_asynchronously :solr_index, queue: 'index' unless Rails.env.test?

  # Return week day of start date if the course associated to the planning
  # is not a lesson
  #
  # @return Integer
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

  # Return the length of the planning regarding start and end date
  #
  # @return Integer
  def length
    return ((end_date || start_date) - start_date).to_i + 1
  end

  # :nocov:
  def min_price_amount_for(type)
    price = price_amount_for_scope(type).order('amount ASC').first
    return 0 unless price
    price.amount.to_i
  end
  # :nocov:

  def week_days
    if self.course.is_lesson? or self.course.is_private?
      [self.week_day]
    else
      if self.start_date and self.end_date
        (self.start_date..self.end_date).to_a.map(&:wday).uniq
      elsif self.start_date
        [self.start_date.wday]
      end
    end
  end

  #
  # Return the next date depending on the week_day if it is a lesson
  #
  # @return Date
  def next_date
    if course.is_training?
      self.start_date
    else
      # See http://stackoverflow.com/a/7621385/900301
      today = Date.today
      if week_day > today.wday
        today + (week_day - today.wday)
      else
        (today + (7 - today.wday)).next_day(week_day)
      end
    end
  end

  def latitude
    if course.teaches_at_home and structure.places.homes.any?
      structure.places.homes.first.latitude
    elsif place
      place.latitude
    elsif course.place
      course.place.latitude
    end
  end

  def longitude
    if course.teaches_at_home and structure.places.homes.any?
      structure.places.homes.first.longitude
    elsif place
      place.longitude
    elsif course.place
      course.place.longitude
    end
  end

  # The periods in which the planning is in. We are inclusing with these periods, meaning that we
  # take slots in which the start_time and the end_time are in.
  #
  # @return an Array of string.
  def periods
    periods = []
    _start_time = start_time.in_time_zone('Paris')
    _end_time   = end_time.in_time_zone('Paris')

    TIME_SLOTS.keys.each do |key|
      slot = TIME_SLOTS[key]
      if _start_time.hour.in?(slot[:start_time]..slot[:end_time])
        periods << slot[:short_name]
      end

      if _end_time.hour.in?(slot[:start_time]..slot[:end_time])
        periods << slot[:short_name]
      end
    end

    periods.uniq
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

  # Set default start date if not defined
  def set_start_date
    if self.start_date.nil? and !self.course.try(:is_training?)
      self.start_date = self.course.start_date || Date.yesterday
    end
  end

  # Set end date if not defined
  def set_end_date
    if end_date.blank? or end_date < Date.today
      if course.try(:is_training?)
        self.end_date = self.start_date
      end
    end
  end

  ######################################################################
  # Validations                                                        #
  ######################################################################

  # Add errors to model if the course associated needs a start date and
  # there is no start_date is not present
  #
  # @return nil
  def presence_of_start_date
    return if course.nil?
    if course.is_training? or course.is_open?
      unless start_date.present?
        errors.add(:start_date, :blank)
      end
    end
  end

  # Add errors to model if there is no place selected
  #
  # @return nil
  def presence_of_place
    return if course.nil?
    unless course.is_private?
      errors.add(:place_id, :blank) if self.place.nil? and self.is_in_foreign_country == false
    end
  end

  # Add errors if end date is not in the future
  #
  # @return [type] [description]
  def end_date_in_future
    if course.is_training?
      if end_date and end_date < Date.today
        errors.add(:end_date, 'Le cours ne peut pas être dans le passé.')
      end
    end
  end

  # Remove the current planning from Delayed Jobs on deletion.
  #
  # TODO: Profile length of method.
  # @return nil
  def remove_from_jobs
    jobs = Delayed::Job.select { |job| YAML.load(job.handler).object == self }
    jobs.each(&:destroy)
  end

  # Destroy card if it was the only planning attached to it
  # @return nil
  def destroy_indexable_cards
    return nil if indexable_card.present?
    indexable_card.destroy if indexable_card.plannings.count == 1
    nil
  end

  def update_structure_meta_datas
    structure.delay.update_planning_meta_datas
  end

  def update_indexable_cards
    IndexableCard.delay.update_from_course(self.course)
  end
end
