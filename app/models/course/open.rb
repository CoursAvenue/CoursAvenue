class Course::Open < Course

  attr_accessible :event_type, :event_type_description, :price, :nb_participants_min, :nb_participants_max, :info

  validates :name, :event_type, :nb_participants_max, presence: true
  validates :nb_participants_max, numericality: { greater_than: :nb_participants_min }
  validates :nb_participants_min, numericality: { greater_than: 0 }

  before_save :set_active

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

  private

  def set_active
    self.active = true
  end
end
