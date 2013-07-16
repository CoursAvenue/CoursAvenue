module ReservationHelper

  def reservable_path reservation
    reservable = reservation.reservable
    case reservation.reservable_type
    when 'Course', 'Course::Training', 'Course::Workshop', 'Course::Lesson'
      place_course_path reservable.place, reservable
    when 'Planning'
      place_course_path reservable.course.place, reservable.course
    when 'Place'
      place_path reservable
    else
      root_path
    end
  end
end
