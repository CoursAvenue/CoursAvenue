class CourseGroup::Training < CourseGroup
  def is_training?
    true
  end

  def length
    if plannings.first.day_five
      5
    elsif plannings.first.day_four
      4
    elsif plannings.first.day_three
      3
    elsif plannings.first.day_two
      2
    elsif plannings.first.day_one
      1
    end
  end

  def minimum_price
    prices.first.individual_course_price
  end
end
