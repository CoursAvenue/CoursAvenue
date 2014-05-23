class Course::Lesson < Course

  validates :start_date, :end_date, presence: true

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

  def latest_end_date
    self.end_date
  end
end
