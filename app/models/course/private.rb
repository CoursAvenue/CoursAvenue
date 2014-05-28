class Course::Private < Course
  # extend ActiveHashHelper
  include Concerns::ActiveHashHelper
  include Concerns::HasAudiencesAndLevels

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :place

  attr_accessible :place, :min_age_for_kid, :max_age_for_kid, :on_appointment, :teaches_at_home

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_save :create_hidden_plannings
  before_save :set_start_and_end_date

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
    self.structure.places.homes.first
  end

  private

  #
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
end
