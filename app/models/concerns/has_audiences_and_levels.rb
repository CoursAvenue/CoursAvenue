module Concerns
  module HasAudiencesAndLevels
    extend ActiveSupport::Concern

    include ::Concerns::ActiveHashHelper

    included do
      self.define_has_many_for :audience
      self.define_has_many_for :level

      before_validation :set_audience_if_empty
      before_validation :set_level_if_empty

      validates :audience_ids, :level_ids, presence: true
      validates :min_age_for_kid, numericality: { less_than: 18 }, allow_nil: true
      validates :max_age_for_kid, numericality: { less_than: 19 }, allow_nil: true
      validate :min_age_must_be_less_than_max_age
    end


    # Return if KID audience is included in audiences
    #
    # @return Boolean
    def for_kid?
      audiences.include? Audience::KID
    end

    # Return if ADULT audience is included in audiences
    #
    # @return Boolean
    def for_adult?
      audiences.include? Audience::ADULT
    end

    # Return if SENIOR audience is included in audiences
    #
    # @return Boolean
    def for_senior?
      audiences.include? Audience::SENIOR
    end

    private

    # Set audience to Adult if none is set
    #
    # @return audiences
    def set_audience_if_empty
      self.audiences = [Audience::ADULT] if self.audiences.empty?
    end

    # Set level to All if none is set
    #
    # @return levels
    def set_level_if_empty
      self.levels = [Level::ALL] if self.levels.empty?
    end

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
end
