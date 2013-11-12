class PlanningSerializer < ActiveModel::Serializer
  include PlanningsHelper

  attributes :week_day, :duration, :time_slot, :levels, :audiences, :price

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

  def audiences
    join_audiences_text(object)
  end

  def price
  end
end
