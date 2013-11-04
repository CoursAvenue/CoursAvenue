class PlanningSerializer < ActiveModel::Serializer
  include PlanningsHelper

  attributes :week_day, :duration, :time_slot, :levels

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
end

class CourseSerializer < ActiveModel::Serializer

  attributes :id, :name, :type, :start_date, :end_date
  has_many :plannings

end
