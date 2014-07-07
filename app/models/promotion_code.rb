# encoding: utf-8
class PromotionCode < ActiveRecord::Base

  attr_accessible :name, :code_id, :promo_amount, :plan_type, :expires_at, :usage_nb, :max_usage_nb

  validates :name, :code_id, :promo_amount, :plan_type, presence: true

  def expired?
  end

end
