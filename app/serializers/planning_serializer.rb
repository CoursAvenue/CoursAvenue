class PlanningSerializer < ActiveModel::Serializer
  include PlanningsHelper
  include PricesHelper

  attributes :id, :date, :duration, :time_slot, :levels, :audiences, :place_id,
             :course_id, :info, :address, :address_with_info, :address_name, :home_place_id,
             :next_date, :week_day, :address_lat, :address_lng, :start_date_datetime,
             :end_date_datetime, :teaches_at_home

  def teaches_at_home
    if (object.course.is_private? and object.course.teaches_at_home?) or
        (object.place and object.place.is_home?)
      true
    else
      false
    end
  end

  def home_place_id
    if object.course.is_private? and object.course.teaches_at_home?
      (@options[:structure] || object.course.structure).places.homes.first.try(:id)
    end
  end

  def place_id
    place.id if place
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
      planning_date_for(object).capitalize
    end
  end

  def duration
    if object.course.is_training? and object.length > 1
      "#{object.length} jours"
    else
      readable_duration(object.duration)
    end
  end

  def time_slot
    object.decorate.time_slot
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

  def place
    if object.course.is_private?
      object.course.place
    else
      object.place
    end
  end

  def city
    place.try(:city)
  end

  def address_lat
    city.latitude if city
  end

  def address_lng
    city.longitude if city
  end

  def start_date_datetime
    start_time      = object.start_time
    next_start_time = DateTime.new(object.next_date.year, object.next_date.month, object.next_date.day, start_time.hour, start_time.min)
    # −06:00 is the french Timezone in ISO format
    I18n.l(next_start_time, format: :iso_date_8601).gsub(/Z$/, '') + '−06:00'
  end

  def end_date_datetime
    end_time      = object.end_time
    next_end_time = DateTime.new(object.next_date.year, object.next_date.month, object.next_date.day, end_time.hour, end_time.min)
    # −06:00 is the french Timezone in ISO format
    I18n.l(next_end_time, format: :iso_date_8601).gsub(/Z$/, '') + '−06:00'
  end

end
