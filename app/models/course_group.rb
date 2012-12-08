# CourseGroups are grouped by same name, audiences and levels
class CourseGroup < ActiveRecord::Base

  # For pagination
  self.per_page = 15

  belongs_to :structure

  has_many :courses  , dependent: :destroy

  has_many :plannings, through: :courses
  has_many :prices   , through: :courses

  has_and_belongs_to_many :audiences
  has_and_belongs_to_many :levels

  belongs_to :discipline

  attr_accessible :name

  def self.with_name_like(name_string)
    name_string    = '%' + name_string + '%'
    self.joins{structure}.where{(name =~ name_string) | (structure.name =~ name_string)}
  end

  def self.is_of_type(types_array)
    types = []
    types << 'CourseGroup::Lesson'   if types_array.include? 'lesson'
    types << 'CourseGroup::Training' if types_array.include? 'training'
    self.where{type.like_any types}
  end

  def self.is_for_audience(audience_ids)
    self.joins{audiences}.where{audiences.id.eq_any audience_ids.map(&:to_i)}
  end

  def self.is_for_age(age)
    self.joins{courses}.where{(courses.min_age_for_kid < age) & (courses.max_age_for_kid > age)}
  end

  def self.is_for_level(level_ids)
    self.joins{levels}.where{levels.id.eq_any level_ids}
  end

  def self.that_happens(week_days)
    self.joins{plannings}.where{(type == 'CourseGroup::Training') | (plannings.week_day.like_any week_days)}
  end

  def self.in_these_time_slots(values)
    time_slots = []
    values.each do |slot|
      start_time = TimeParser.parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:start_time]
      end_time   = TimeParser.parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:end_time]
      time_slots << [start_time, end_time]
    end
    self.joins{plannings}.where do
      time_slots.map { |start_time, end_time| ((plannings.start_time >= start_time) & (plannings.start_time <= end_time)) }.reduce(&:|)
    end
  end

  def self.in_time_range(start_time, end_time)
    start_time = TimeParser.parse_time_string( start_time.blank? ? '00:00' : start_time )
    end_time   = TimeParser.parse_time_string( end_time.blank?   ? '23:59' : end_time )

    self.joins{plannings}.where{(plannings.start_time >= start_time) & (plannings.end_time <= end_time)}
  end

  def self.in_price_range(min_price, max_price)
    min_price = 0     if min_price.blank? and !max_price.blank?
    max_price = 10000 if max_price.blank? and !min_price.blank?
    if !min_price.blank? and !max_price.blank? and max_price.to_i > 0
      return self.joins{prices}.where{(prices.approximate_price_per_course >= min_price) & (prices.approximate_price_per_course <= max_price)}
    end
    self
  end

  def is_lesson?
    false
  end

  def is_training?
    false
  end

  def best_price
    prices.order('approximate_price_per_course ASC').first
  end

  def type_name
    'Cours'
  end
end
