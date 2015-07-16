class Guide::AgeRestriction < ActiveRecord::Base
  attr_accessible :min_age, :max_age

  belongs_to :guide

  validate :has_at_least_one_age

  private

  def has_at_least_one_age
    if self.min_age.nil? and self.max_age.nil?
      errors.add(:min_age, :blank)
      errors.add(:max_age, :blank)
    end
  end
end
