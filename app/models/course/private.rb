class Course::Private < Course
  # extend ActiveHashHelper
  include Concerns::ActiveHashHelper
  include Concerns::HasAudiencesAndLevels

  attr_accessible :place, :min_age_for_kid, :max_age_for_kid, :on_appointment, :teaches_at_home

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_initialize :default_values

  after_create :set_gives_individual_courses_if_false

  after_save :create_hidden_plannings
  before_save :set_start_and_end_date

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validate :place_or_teaches_at_home

  has_many :prices, -> { where(type: 'Price::Trial').limit(1) }, foreign_key: 'course_id'

  def is_private?
    true
  end

  def type_name
    'Cours particulier'
  end

  def self.underscore_name
    'private'
  end

  def underscore_name
    self.class.underscore_name
  end

  def home_place
    self.structure.places.homes.first if teaches_at_home
  end

  def expired?
    false
  end

  def is_individual?
    true
  end

  def can_be_published?
    plannings.any? and price_group.present?
  end

  def places
    if teaches_at_home
      [self.home_place, self.place].compact
    else
      [self.place].compact
    end
  end

  private

  # Creates plannings for each days if the course is on_appointment (meaning
  # the student has to ask first the teacher to know availability.
  #
  # @return nil
  def create_hidden_plannings
    if on_appointment_changed?
      self.plannings.map(&:destroy)
      if self.on_appointment
        (0..6).each do |week_day|
          self.plannings.create(week_day: week_day,
                                visible: false,
                                start_time: Time.parse('2000-01-01 06:00:00 UTC'),
                                start_date: Date.yesterday,
                                end_time: Time.parse('2000-01-01 23:00:00 UTC'),
                                end_date: Date.today + 100.years)
        end
      end
    end
    nil
  end

  def set_start_and_end_date
    self.start_date = Date.yesterday         if start_date.nil?
    self.end_date   = Date.today + 100.years if end_date.nil?
  end

  #
  # A course have to have a place OR teaches_at_home with a place
  #
  # @return [type] [description]
  def place_or_teaches_at_home
    if (teaches_at_home.nil? or teaches_at_home == false) and place.nil?
      errors.add :place_id, :blank
    end
  end

  def default_values
    if self.new_record?
      self.audiences = [Audience::ADULT] if self.audiences.empty?
      self.levels    = [Level::ALL]      if self.levels.empty?
    end
  end

  # If a user creates a private course, then by default, it will set the teaches
  # at home flag of structure to true.
  #
  # @return nil
  def set_gives_individual_courses_if_false
    self.structure.gives_individual_courses = true
    self.structure.save
    nil
  end
end
