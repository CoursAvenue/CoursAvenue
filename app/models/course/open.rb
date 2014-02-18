class Course::Open < Course

  attr_accessible :event_type, :event_type_description, :price, :nb_participants_min, :nb_participants_max, :info

  validates :name, :event_type, :nb_participants_min, :nb_participants_max, presence: true
  validates :nb_participants_min, numericality: { greater_or_equal_than: 0 }
  validates :nb_participants_max, numericality: { greater_than: :nb_participants_min },
                                  unless: Proc.new {|course| course.nb_participants_min.nil? || course.nb_participants_max.nil? }
  before_save :set_active

  after_save :alert_participants_for_changes
  before_destroy :alert_participants_for_deletion

  has_many :participations, through: :plannings

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

  def alert_participants_for_changes
    self.plannings.each do |planning|
      planning.participations.map(&:alert_for_changes)
    end
  end

  def alert_participants_for_deletion
    self.plannings.each do |planning|
      planning.participations.map(&:alert_for_destroy)
    end
  end
end
