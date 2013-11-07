class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper
  include ActionView::Helpers::TextHelper

  attributes :id, :name, :type, :start_date, :end_date, :min_price_amount, :min_price_libelle, :data_url, :subjects
  has_many :plannings

  def is_individual
    self.is_individual?
  end

  def teaches_at_home
    self.teaches_at_home?
  end

  def min_price_amount
    object.best_price.amount.to_i if object.best_price
  end

  def min_price_libelle
    object.best_price.localized_libelle.downcase if object.best_price
  end

  def type
    plain_type_name(object)
  end

  def start_date
    I18n.l(object.start_date, format: :short) if object.start_date
  end

  def end_date
    I18n.l(object.end_date, format: :short) if object.end_date
  end

  def data_url
    structure_course_path(object.structure, object)
  end

  def subjects
    truncate(object.subjects.map(&:name).join(', '), length: 50)
  end
end
