class Course::Lesson < Course

  has_many :prices, -> { where(type: 'Price::Trial').limit(1) }, foreign_key: 'course_id'

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
