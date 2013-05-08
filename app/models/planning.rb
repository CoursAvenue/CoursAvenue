# encoding: utf-8
class Planning < ActiveRecord::Base
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

  # validates :teacher, presence: true
  validate :presence_of_start_date
  validate :end_date_in_future


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
                  :teacher_id

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

  private

  def update_duration
    if self.start_time and self.end_time
      time_at = Time.zone.at(self.end_time - self.start_time)
      self.duration = (time_at.hour * 60) + time_at.min
    end
  end

  def set_end_time
    unless self.end_time.present?
      if self.start_time and self.duration
        self.end_time = self.start_time + self.duration.minutes
      end
    end
  end

  def set_start_date
    if start_date.nil?
      self.start_date = course.start_date || Date.yesterday
    end
  end

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
        errors.add(:end_date, :blank)
      end
    end
  end

  def end_date_in_future
    if end_date and end_date < Date.today
      errors.add(:error_notification, 'Le cours ne peut pas être dans le passé.')
    end
  end
end
