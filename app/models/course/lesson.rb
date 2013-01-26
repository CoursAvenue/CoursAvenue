class Course::Lesson < Course

  def is_lesson?
    true
  end

  def minimum_price_per_course
    prices.order('individual_course_price ASC').first.individual_course_price
  end

  def minimum_price_per_year
    prices.order('annual_price ASC').first.annual_price
  end

  def type_name
    'Cours'
  end

end
