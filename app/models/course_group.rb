# encoding: utf-8
# CourseGroups are grouped by same name, audiences and levels
class CourseGroup < ActiveRecord::Base

  # ------------------------------------------------------------------------------------ Model attributes and settings
  extend FriendlyId
  friendly_id :name, use: :slugged

  # For pagination
  self.per_page = 15

  belongs_to :structure

  has_many :courses  , dependent: :destroy

  has_many :plannings, through: :courses
  has_many :prices   , through: :courses

  has_and_belongs_to_many :audiences
  has_and_belongs_to_many :levels

  belongs_to :discipline

  attr_accessible :name, :has_online_payment, :description


  # ------------------------------------------------------------------------------------ Self methods

  def self.from_city(city, scope)
    scope.joins{structure}.where{structure.city == city}
  end

  def self.of_discipline(discipline_name, scope)
    if discipline_name == I18n.t('all_discipline_route_name')
      return scope
    else
      discipline_object = Discipline.where{name == discipline_name}.first
      if discipline_object.parent_id.nil?
        discipline_ids = discipline_object.children.map(&:id)
      else
        discipline_ids = [discipline_object.id]
      end
      return scope.where{discipline_id.eq_any discipline_ids}
    end
  end

  def self.name_and_structure_name_contains(name_string, scope)
    name_string    = '%' + name_string + '%'
    scope.joins{structure}.where{(name =~ name_string) | (structure.name =~ name_string)}
  end

  def self.is_of_type(types_array, scope)
    types = []
    types << 'CourseGroup::Lesson'   if types_array.include? 'lesson'
    types << 'CourseGroup::Training' if types_array.include? 'training'
    types << 'CourseGroup::Workshop' if types_array.include? 'workshop'
    scope.where{type.like_any types}
  end

  def self.has_price_specificities(price_specificities, scope)
    return scope if price_specificities.length == 3 # Doesn't search if all options are checked
    scope = scope.joins{prices}.where do
      query = nil
      price_specificities.each_with_index do |price_specificity|
        case price_specificity
        when 'has_unit_course_price'
          if query then query |= (prices.individual_course_price != nil) else query = (prices.individual_course_price != nil) end
        when 'has_package_price'
          if query
            query |= (prices.annual_price != nil) | (prices.semester_price != nil) | (prices.trimester_price != nil) | (prices.month_price != nil)
          else
            query =  (prices.annual_price != nil) | (prices.semester_price != nil) | (prices.trimester_price != nil) | (prices.month_price != nil)
          end
        when 'has_test_course'
          if query then query |= (prices.trial_lesson_price != nil) else query = (prices.trial_lesson_price != nil) end
        end
      end
      query
    end

    scope
  end

  def self.is_for_audience(audience_ids, scope)
    scope.joins{audiences}.where{audiences.id.eq_any audience_ids.map(&:to_i)}
  end

  def self.is_for_age(age, scope)
    if age.to_i > 18
      scope
    else
      scope.joins{courses}.where{(courses.min_age_for_kid < age) & (courses.max_age_for_kid > age)}
    end
  end

  def self.is_for_level(level_ids, scope)
    scope.joins{levels}.where{levels.id.eq_any level_ids}
  end

  def self.that_happens(week_day_indexes, scope)
    scope.joins{plannings}.where{(type == 'CourseGroup::Training') | ((type == 'CourseGroup::Lesson') & (plannings.week_day.eq_any week_day_indexes.map(&:to_i))) | ((type == 'CourseGroup::Workshop') & (plannings.week_day.eq_any week_day_indexes.map(&:to_i)))}
  end

  def self.in_these_time_slots(values, scope)
    time_slots = []
    values.each do |slot|
      start_time = TimeParser.parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:start_time]
      end_time   = TimeParser.parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:end_time]
      time_slots << [start_time, end_time]
    end
    scope.joins{plannings}.where do
      time_slots.map { |start_time, end_time| ((plannings.start_time >= start_time) & (plannings.start_time <= end_time)) }.reduce(&:|)
    end
  end

  def self.in_time_range(start_time, end_time, scope)
    if start_time.blank? and end_time.blank?
      scope
    else
      start_time = TimeParser.parse_time_string( start_time.blank? ? '00:00' : start_time )
      end_time   = TimeParser.parse_time_string( end_time.blank?   ? '23:59' : end_time )

      scope.joins{plannings}.where{(plannings.start_time >= start_time) & (plannings.end_time <= end_time)}
    end
  end

  def self.in_price_range(min_price, max_price, scope)
    if min_price.blank? and max_price.blank?
      scope
    else
      min_price = 0     if min_price.blank? and !max_price.blank?
      max_price = 10000 if max_price.blank? and !min_price.blank?
      if !min_price.blank? and !max_price.blank? and max_price.to_i > 0
        scope.joins{prices}.where{(prices.approximate_price_per_course >= min_price) & (prices.approximate_price_per_course <= max_price)}
      end
    end
  end

  # ------------------------------------------------------------------------------------ Callbacks

  # Called afer a course has been saved
  def update_has_promotion
   # Will set has_promotion to true if one of the courses has a promotion higher than 0
   self.has_promotion = !self.courses.index do |course|
      !course.promotion.nil? and course.promotion > 0
    end.nil?
    self.save
  end

  # TODO: To be improved
  def similar_courses(limit = 5)
    similar_courses = CourseGroup.where{discipline_id == self.discipline_id}.limit(limit) # With same discipline
    similar_courses
  end

  def promotion
    self.courses.order('promotion ASC').first.promotion
  end

  def is_workshop?
    false
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
