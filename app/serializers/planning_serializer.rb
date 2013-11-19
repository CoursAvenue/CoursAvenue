class PlanningSerializer < ActiveModel::Serializer
  include PlanningsHelper

  attributes :date, :duration, :time_slot, :levels, :audiences, :price, :place_id

  def date
    if object.course.is_lesson?
      week_day_for(object)
    else
      planning_date_for object
    end
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

  def audiences
    join_audiences_text(object)
  end

  def price
  end
end
