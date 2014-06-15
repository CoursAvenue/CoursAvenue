class PlanningSerializer < ActiveModel::Serializer
  include PlanningsHelper
  include PricesHelper

  attributes :id, :date, :duration, :time_slot, :levels, :audiences, :place_id, :places_left, :more_than_ten_places,
             :common_price, :course_id, :info, :address

  def address
    object.place.address if object.place
  end

  def date
    if object.course.is_lesson? or object.course.is_private?
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
    join_audiences(object)
  end

  def places_left
    object.places_left if @options[:jpo]
  end

  def more_than_ten_places
    object.places_left > 10 if @options[:jpo]
  end

  def common_price
    readable_amount(object.course.common_price) if object.course.common_price
  end
end
