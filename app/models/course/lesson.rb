class Course::Lesson < Course

  def is_lesson?
    true
  end

  def type_name
    'Cours collectif'
  end

  def self.underscore_name
    'lesson'
  end

  def underscore_name
    self.class.underscore_name
  end

  def expired?
    return false
  end
end
