# encoding: utf-8
class PromotionCode < ActiveRecord::Base

  attr_accessible :name, :code_id, :promo_amount, :plan_type, :expires_at, :usage_nb, :max_usage_nb

  validates :name, :code_id, :promo_amount, :plan_type, :max_usage_nb, presence: true
  validates :code_id, uniqueness: true

  # Don't use `valid?` because taken by Rails
  # Tells wether or not the plan is valid
  #
  # @return Boolean
  def still_valid? subscription_plan
    return (!self.expired? and (usage_nb < max_usage_nb) and plan_type == subscription_plan.plan_type)
  end

  def expired?
    expires_at < Date.today
  end

  # Increment usage_nb by 1
  #
  # @return Integer usage_nb
  def increment!
    usage_nb += 1
  end
end
