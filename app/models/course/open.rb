class Course::Open < Course

  attr_accessible :event_type, :event_type_description, :price, :nb_participants_min, :nb_participants_max,
                  :info, :ca_follow_up, :common_price, :ok_nico

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name, :event_type, :nb_participants_min, :nb_participants_max, presence: true
  validates :nb_participants_min, numericality: { greater_or_equal_than: 0 }
  validates :nb_participants_max, numericality: { greater_than: :nb_participants_min },
                                  unless: Proc.new {|course| course.nb_participants_min.nil? || course.nb_participants_max.nil? }

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_many :participations, through: :plannings

  def is_open?
    true
  end

  def free?
    price.nil? or price == 0
  end

  def type_name
    'Journée portes ouvertes'
  end

  def underscore_name
    'open_course'
  end

  def other_event_type?
    event_type == 'other'
  end

  # Activate the course and sends ends an email to the admin if this courses
  # becomes active and ALL other JPO courses are already active
  #
  # @return Boolean if course saved or not
  def activate!
    self.active = true
    saved_value = self.save
    # Save before checking
    if self.structure.courses.open_courses.map(&:active?).all?
      AdminMailer.delay.your_jpo_courses_are_visible(structure)
    end
    self.index
    return saved_value
  end
end
