# encoding: utf-8
# Courses are grouped by same name, audiences and levels
class Course < ActiveRecord::Base

  # ------------------------------------------------------------------------------------ Model attributes and settings
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_attached_file :homepage_image, :styles => {default: '1600×500#'}
  has_attached_file :image, :styles => { wide: "600x375#", thumb: "200x200#" }

  belongs_to :structure

  has_many :plannings
  has_many :prices           , dependent: :destroy
  has_many :book_tickets     , dependent: :destroy
  has_many :registration_fees, dependent: :destroy

  has_and_belongs_to_many :audiences
  has_and_belongs_to_many :levels

  has_and_belongs_to_many :disciplines, :uniq => true

  # ------------------------------------------------------------------------------------ Validations
  validates :structure, presence: true

  # ------------------------------------------------------------------------------------ Callbacks
  before_update :rollback_slug_change


  attr_accessible :name,
                  :has_online_payment,
                  :homepage_image,
                  :is_promoted,
                  :description,
                  :has_promotion,
                  :course_info,
                  :registration_date,
                  :teacher_name,
                  :min_age_for_kid,
                  :max_age_for_kid,
                  :is_individual,
                  :annual_membership_mandatory,
                  :is_for_handicaped,
                  :trial_lesson_info,
                  :price_details,
                  :price_info,
                  :conditions,
                  :partner_rib_info,
                  :audition_mandatory,
                  :refund_condition,
                  :cant_be_joined_during_year

  # ------------------------------------------------------------------------------------ Self methods

  def self.from_city(city, scope)
    city_id = City.where{short_name == city}.first.id
    scope.joins{structure}.where{structure.city_id == city_id}
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
      return scope.joins{disciplines}.where{disciplines.id.eq_any discipline_ids}
    end
  end

  def self.name_and_structure_name_contains(name_string, scope)
    name_string    = '%' + name_string + '%'
    scope.joins{structure}.where{(name =~ name_string) | (structure.name =~ name_string)}
  end

  def self.is_of_type(types_array, scope)
    types = []
    types << 'Course::Lesson'   if types_array.include? 'lesson'
    types << 'Course::Training' if types_array.include? 'training'
    types << 'Course::Workshop' if types_array.include? 'workshop'
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

  def self.is_for_ages(age, scope)
    if age[:min].blank? and age[:max].blank?
      scope
    else
      age[:min] = 0  if age[:min].blank?
      age[:max] = 18 if age[:max].blank?
      if age[:min].to_i > 18
        scope
      else
        scope.where{(min_age_for_kid < age[:max]) & (max_age_for_kid > age[:min])}
      end
    end
  end

  def self.is_for_level(level_ids, scope)
    scope.joins{levels}.where{levels.id.eq_any level_ids}
  end

  def self.that_happens(week_day_indexes, scope)
    scope.joins{plannings}.where{(type == 'Course::Training') | ((type == 'Course::Lesson') & (plannings.week_day.eq_any week_day_indexes.map(&:to_i))) | ((type == 'Course::Workshop') & (plannings.week_day.eq_any week_day_indexes.map(&:to_i)))}
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
        scope.joins{prices}.where{(prices.amount >= min_price.to_i) & (prices.amount <= max_price.to_f)}
      end
    end
  end

  # TODO: To be improved
  def similar_courses(limit = 5)
    discipline_ids = self.discipline_ids.map(&:to_i)
    similar_courses = Course.joins{disciplines}.where{disciplines.id.eq_any discipline_ids}.limit(limit) # With same discipline
    if similar_courses.length < 5
      max_id    = Course.maximum("id")
      min_id    = Course.minimum("id")
      id_range  = max_id - min_id + 1
      random_id = min_id + rand(id_range).to_i
      similar_courses = Course.limit(limit).offset(random_id)
    end
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
    prices.where{amount > 0}.order('amount ASC').first
  end

  def type_name
    'Cours'
  end

  protected
  def rollback_slug_change
    self.slug = slug_was if slug_changed?
  end
end
