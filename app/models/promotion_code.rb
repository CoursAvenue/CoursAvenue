# encoding: utf-8
class PromotionCode < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :name, :code_id, :promo_amount, :plan_type, :expires_at, :usage_nb, :max_usage_nb, :canceled

  validates :name, :code_id, :promo_amount, :plan_type, :max_usage_nb, presence: true
  validates :code_id, uniqueness: true

  # Don't use `valid?` because taken by Rails
  # Tells wether or not the plan is valid
  #
  # @param subscription_plan=nil Can pass a subscription_plan to see if valid regarding subscription_plan
  # @return Boolean
  def still_valid? subscription_plan=nil
    return (!self.expired? and (usage_nb < max_usage_nb) and plan_type == subscription_plan.plan_type) if subscription_plan
    return (!self.expired? and (usage_nb < max_usage_nb))
  end

  def expired?
    expires_at < Date.today
  end

  # Increment usage_nb by 1
  #
  # @return Integer usage_nb
  def increment!
    self.usage_nb = (usage_nb || 0) + 1
    self.save
  end

  def promo_amount_for_be2bill
    promo_amount * 100
  end

  def canceled?
    self.canceled_at.present?
  end

  def cancel!
    self.canceled_at = Time.now
    self.save
  end

end
