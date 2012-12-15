class CourseGroup::Workshop < CourseGroup

  def is_workshop?
    true
  end

  def minimum_price
    prices.first.individual_course_price
  end

  def type_name
    'Cours-atelier'
  end

end
