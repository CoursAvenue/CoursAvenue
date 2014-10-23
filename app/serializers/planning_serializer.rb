class PlanningSerializer < ActiveModel::Serializer
  include PlanningsHelper
  include PricesHelper

  attributes :id, :date, :duration, :time_slot, :levels, :audiences, :place_id,
             :course_id, :info, :address, :address_with_info, :address_name, :home_place_id,
             :next_date, :week_day

  def home_place_id
    if object.course.is_private? and object.course.teaches_at_home?
      (@options[:structure] || object.course.structure).places.homes.first.try(:id)
    end
  end

  def place_id
    if object.course.is_private?
      object.course.place_id
    else
      object.place_id
    end
  end

  def address
    object.place.address if object.place
  end

  def address_with_info
    str = ''
    if object.course.is_private?
      if object.course.place
        str << "<div><strong>#{object.course.place.address}#{(object.course.place.info.present? ? ' : ' : '')}</strong></div>"
        str << "<div>#{object.course.place.info}</strong></div>" if object.course.place.info.present?
      end
      if object.course.home_place
        str << "<div><strong>#{object.course.home_place.name}</strong> :<br> #{object.course.home_place.address}</div>"
      end
    elsif object.place
      str << "<div><strong>#{object.place.address}#{(object.place.info.present? ? ' : ' : '')}</strong></div>"
      str << "<div>#{object.place.info}</strong></div>" if object.place.info.present?
    end
    str
  end

  def address_name
    places = []
    if object.is_in_foreign_country?
      fake_place = Struct.new(:name)
      _place = fake_place.new I18n.t('places.is_in_foreign_country')
      places << _place
    end
    if object.course.is_private?
      places << object.course.home_place if object.course.home_place
      places << object.course.place if object.course.place
    else
      places << object.place if object.place
    end
    places.map(&:name).join(', ')
  end

  def date
    if object.course.is_lesson? or object.course.is_private?
      week_day_for(object)
    else
      _date = "#{planning_date_for(object)}".capitalize
      _date << " (#{object.length} jours)" if object.length > 1
      _date
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
    if object.course.is_private?
      join_audiences(object.course)
    else
      join_audiences(object)
    end
  end

  def next_date
    I18n.l(object.next_date)
  end
end
