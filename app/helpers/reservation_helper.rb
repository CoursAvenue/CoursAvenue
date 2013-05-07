module ReservationHelper

  def reservable_path reservation
    reservable = reservation.reservable
    case reservation.reservable_type
    when 'Course', 'Course::Training', 'Course::Workshop', 'Course::Lesson'
      course_path reservable
    when 'Planning'
      course_path reservable.course
    when 'Place'
      place_path reservable
    else
      root_path
    end
  end
end
