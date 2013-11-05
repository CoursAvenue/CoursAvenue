class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper

  attributes :id, :name, :type, :start_date, :end_date, :price_range
  has_many :plannings

  def price_range
    plain_price_range(object)
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
end
