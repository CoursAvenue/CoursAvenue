class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :description, :type, :start_date, :end_date, :min_price_amount, :min_price_libelle, :data_url, :subjects,
             :has_free_trial_lesson, :event_type, :best_price, :is_individual, :search_term

  has_many :plannings, serializer: PlanningSerializer

  def plannings
    object.plannings.future.ordered_by_day
  end

  def has_free_trial_lesson
    object.has_free_trial_lesson?
  end

  def is_individual
    object.is_individual?
  end

  def teaches_at_home
    self.teaches_at_home?
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

  def start_date
    I18n.l(object.start_date, format: :short) if object.start_date
  end

  def end_date
    I18n.l(object.end_date, format: :short) if object.end_date
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
end
