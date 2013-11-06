class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper

  attributes :id, :name, :type, :start_date, :end_date, :price_range, :min_price_amount, :min_price_libelle
  has_many :plannings

  def price_range
    plain_price_range(object)
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
end
