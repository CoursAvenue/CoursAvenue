# encoding: utf-8
class Planning < ActiveRecord::Base
  acts_as_paranoid

  include PlanningsHelper

  belongs_to :course, touch: true
  has_many   :prices, through: :course
  belongs_to :room
  belongs_to :teacher

  has_many :reservations,         as: :reservable

  has_one   :structure, through: :course
  has_one   :place,     through: :course

  has_and_belongs_to_many :users

  before_validation :set_start_date
  before_validation :set_end_date
  before_validation :set_end_time
  before_validation :update_duration

  after_initialize :default_values

  # validates :teacher, presence: true
  validates :audience_ids, :level_ids, presence: true
  validate :presence_of_start_date
  validate :end_date_in_future
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
                  :total_nb_place,
                  :nb_place_available,
                  :promotion,
                  :info,
                  :min_age_for_kid,
                  :max_age_for_kid,
                  :teacher,
                  :teacher_id,
                  :level_ids,
                  :audience_ids

  scope :future, where("plannings.end_date > '#{Date.today}'")
  scope :past,   where("plannings.end_date <= '#{Date.today}'")

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

  private

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
    if course.is_workshop? or course.is_training?
      unless start_date.present?
        errors.add(:start_date, :blank)
      end
    end
  end

  def end_date_in_future
    if end_date and end_date < Date.today
      errors.add(:end_date, 'Le cours ne peut pas être dans le passé.')
    end
  end
end
