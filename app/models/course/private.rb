class Course::Private < Course
  # extend ActiveHashHelper
  include Concerns::ActiveHashHelper
  include Concerns::HasAudiencesAndLevels

  # define_has_many_for :audience
  # define_has_many_for :level

  belongs_to :place

  # validates :audience_ids, :level_ids, presence: true
  # validates :min_age_for_kid, numericality: { less_than: 18 }, allow_nil: true
  # validates :max_age_for_kid, numericality: { less_than: 19 }, allow_nil: true

  # validate :min_age_must_be_less_than_max_age

  attr_accessible :place, :min_age_for_kid, :max_age_for_kid

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

  ######################################################################
  # Validations                                                        #
  ######################################################################

  # Add errors to model if min_age < max_age
  #
  # @return nil
  def min_age_must_be_less_than_max_age
    if (max_age_for_kid.present? or min_age_for_kid.present?) and min_age_for_kid.to_i >= max_age_for_kid.to_i
      self.errors.add(:max_age_for_kid, "L'age maximum ne peut être inférieur à l'age minimum")
    end
  end
end
