class Course::Lesson < Course

  def is_lesson?
    true
  end

  def type_name
    'Cours'
  end

  def slug_type_name
    'cours'
  end

end
