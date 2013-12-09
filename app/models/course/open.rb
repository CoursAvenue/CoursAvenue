class Course::Open < Course

  attr_accessible :event_type, :event_type_description, :price

  validates :event_type, :price, presence: true

  def is_open?
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
