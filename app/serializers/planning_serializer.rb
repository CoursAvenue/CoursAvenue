class PlanningSerializer < ActiveModel::Serializer
  include PlanningsHelper
  include PricesHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :date, :duration, :time_slot, :levels, :audiences, :place_id,
             :course_id, :info, :address, :address_with_info, :address_name, :home_place_id,
             :next_date, :week_day, :address_lat, :address_lng, :start_date, :start_hour,
             :start_min, :end_date, :end_hour, :end_min, :teaches_at_home

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

  def start_hour
    object.start_time.hour
  end

  def start_min
    object.start_time.min
  end

  def end_hour
    object.end_time.hour
  end

  def end_min
    object.end_time.min
  end
end
