# encoding: utf-8
class Place::Home < Place

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :city     , presence: true
  validates :zip_code , presence: true, numericality: { only_integer: true }
  validates :radius   , presence: true, numericality: { only_integer: true }

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :set_gives_individual_courses_if_false
  after_destroy :set_teaches_at_home_to_false

  def name
    I18n.t('places.home.name')
  end

  def street
    I18n.t('places.home.street', zip_code: zip_code, city_name: city.name, radius: radius) unless city.nil?
  end

  def address
    street
  end

  def is_home?
    true
  end

  private

  # If a user creates a private course, then by default, it will set the teaches
  # at home flag of structure to true.
  #
  # @return nil
  def set_gives_individual_courses_if_false
    self.structure.gives_individual_courses = true
    self.structure.teaches_at_home          = true
    self.structure.save
    nil
  end

  # If a user destroys a private course, then by default, it will set the teaches
  # at home flag of structure to false.
  #
  # @return nil
  def set_teaches_at_home_to_false
    self.structure.teaches_at_home          = false
    self.structure.save
    nil
  end
end
