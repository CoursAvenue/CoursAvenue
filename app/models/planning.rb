# encoding: utf-8
class Planning < ActiveRecord::Base
  include PlanningsHelper

  belongs_to :course
  has_many   :prices, through: :course
  belongs_to :room
  belongs_to :teacher

  has_one   :structure, through: :course

  before_validation :set_end_date
  before_validation :set_end_time
  before_validation :set_duration

  validates :teacher, presence: true
  validate :presence_of_start_date
  validate :end_date_in_future


  attr_accessible :duration,
                  :end_date,
                  :start_date,
                  :start_time, # Format: Time.parse("2000-01-01 #{value} UTC")
                  :end_time,   # Format: Time.parse("2000-01-01 #{value} UTC")
                  :week_day, # 0: Dimanche, 1: Lundi, as per I18n.t('date.day_names')
                  :class_during_holidays,
                  :nb_place_available,
                  :promotion,
                  :info,
                  :teacher_name, # To remove
                  :min_age_for_kid,
                  :max_age_for_kid,
                  :teacher,
                  :teacher_id,
                  # For Trainings only
                  :day_one,               # To remove
                  :day_one_duration,      # To remove
                  :day_one_start_time,    # To remove
                  :day_two,               # To remove
                  :day_two_duration,      # To remove
                  :day_two_start_time,    # To remove
                  :day_three,             # To remove
                  :day_three_duration,    # To remove
                  :day_three_start_time,  # To remove
                  :day_four,              # To remove
                  :day_four_duration,     # To remove
                  :day_four_start_time,   # To remove
                  :day_five,              # To remove
                  :day_five_duration,     # To remove
                  :day_five_start_time    # To remove

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

  def set_duration
    if self.start_time and self.end_time and duration.nil?
        self.duration = Time.at(self.end_time - self.start_time)
    end
  end

  def set_end_time
    unless self.end_time.present?
      if self.start_time and self.duration
        self.end_time = self.start_time
        self.end_time = self.end_time + self.duration.hour.hours
        self.end_time = self.end_time + self.duration.min.minutes
      end
    end
  end

  def set_end_date
    if course.is_workshop? or course.is_training?
      unless end_date.present?
        self.end_date = self.start_date
      end
    else
      unless end_date.present?
        self.end_date = self.course.end_date
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
