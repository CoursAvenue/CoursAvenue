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

  belongs_to :indexable_card, dependent: :destroy

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_initialize :default_values

  before_validation :set_start_date
  before_validation :set_end_date
  before_validation :set_end_time
  before_validation :update_duration

  before_save :set_structure_if_blank

  # after_save    :update_indexable_cards

  # before_destroy :destroy_indexable_cards
  # before_destroy :update_indexable_cards

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

  # Destroy card if it was the only planning attached to it
  # @return nil
  def destroy_indexable_cards
    return nil if indexable_card.nil?
    indexable_card.destroy if indexable_card.plannings.count == 1
    nil
  end

  def update_indexable_cards
    IndexableCard.delay.update_from_course(self.course)
  end
end
