class Course::Lesson < Course

  def is_lesson?
    true
  end

  def type_name_html
    'Cours'
  end

  def type_name
    'Cours'
  end

  def underscore_name
    'lesson'
  end

  def latest_end_date
    self.end_date
  end
end
