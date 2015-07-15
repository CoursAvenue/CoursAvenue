class Guide::AgeRestriction < ActiveRecord::Base
  belongs_to :guide

  validate :has_at_least_one_age

  private

  def has_at_least_one_age
    if self.min_age.nil? and self.min_age.nil?
      errors.add(:min_age, :blank)
      errors.add(:max_age, :blank)
    end
  end
end
