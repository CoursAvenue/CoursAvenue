class Course::Open < Course

  attr_accessible :event_type, :event_type_description, :price, :nb_participants_min, :nb_participants

  validates :name, :event_type, :nb_participants, presence: true

  def is_open?
    true
  end

  def type_name_html
    'Journée portes ouvertes'
  end

  def type_name
    'Journée portes ouvertes'
  end

  def underscore_name
    'open_course'
  end

  def latest_end_date
    self.end_date
  end

  def other_event_type?
    event_type == 'other'
  end
end
