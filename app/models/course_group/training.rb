class CourseGroup::Training < CourseGroup

  def is_training?
    true
  end

  def length
    plannings.first.length
  end

  def minimum_price
    prices.first.individual_course_price
  end

  def type_name
    'Stage'
  end

end
