# encoding: utf-8
class PromotionCode < ActiveRecord::Base

  attr_accessible :name, :code_id, :promo_amount, :plan_type, :expires_at, :usage_nb, :max_usage_nb

  validates :name, :code_id, :promo_amount, :plan_type, presence: true


  # Tells wether or not the plan is valid
  #
  # @return Boolean
  def valid?
    !expired? and usage_nb < max_usage_nb
  end

  def expired?
    expires_at > Date.today
  end

  # Increment usage_nb by 1
  #
  # @return Integer usage_nb
  def increment!
    usage_nb += 1
  end
end
