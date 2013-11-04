class PlanningSerializer < ActiveModel::Serializer
  include PlanningsHelper

  attributes :week_day, :duration, :time_slot, :levels, :price

  def week_day
    week_day_for(object)
  end

  def duration
    readable_duration object.duration
  end

  def time_slot
    readable_time_slot(object.start_time, object.end_time)
  end

  def levels
    join_levels_text(object)
  end

  def price
  end
end

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
    I18n.l(object.start_date, format: :short)
  end

  def end_date
    I18n.l(object.end_date, format: :short)
  end
end
