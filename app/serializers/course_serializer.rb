class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :description, :type, :start_date, :end_date, :min_price_amount, :min_price_libelle, :data_url, :subjects,
             :has_free_trial_lesson, :event_type, :best_price, :is_individual, :search_term, :plannings_not_shown, :is_lesson, :frequency,
             :cant_be_joined_during_year, :no_class_during_holidays, :teaches_at_home, :teaches_at_home_radius

  has_many :plannings, serializer: PlanningSerializer

  def plannings
    @options[:plannings] || object.plannings.future.ordered_by_day
  end

  def plannings_not_shown
    (options[:plannings].nil?) ? 0 : ( object.plannings.future.ordered_by_day - options[:plannings] ).count
  end

  def has_free_trial_lesson
    object.has_free_trial_lesson?
  end

  def is_individual
    object.is_individual?
  end

  def teaches_at_home
    object.teaches_at_home?
  end

  def teaches_at_home_radius
    object.structure.teaches_at_home_radius
  end

  def best_price
    not object.best_price.nil?
  end

  def min_price_amount
    number_to_currency(object.best_price.try(:amount)) if object.best_price
  end

  def min_price_libelle
    object.best_price.localized_libelle.downcase if object.best_price
  end

  def type
    object.type_name
  end

  def is_lesson
    object.is_lesson?
  end

  def start_date
    I18n.l(object.start_date, format: :semi_short) if object.start_date
  end

  def end_date
    I18n.l(object.end_date, format: :semi_short) if object.end_date
  end

  def data_url
    structure_course_path((@options[:structure] || object.structure), object)
  end

  def subjects
    object.subjects.map(&:name).join(', ')
  end

  def event_type
    if object.other_event_type?
      object.event_type_description
    else
      object.event_type
    end
  end

  def search_term
    options[:search_term] if options[:search_term].present?
  end

  def frequency
    I18n.t(object.frequency) if object.frequency.present?
  end
end
