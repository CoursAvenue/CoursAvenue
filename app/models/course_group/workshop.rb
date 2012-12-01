class CourseGroup::Workshop < CourseGroup
  def is_workshop?
    true
  end

  def minimum_price
    prices.order('individual_course_price ASC').first.individual_course_price
  end

end
