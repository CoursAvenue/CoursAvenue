class PricingPlan < ActiveRecord::Base
  has_many :structures
  attr_accessible :name, :price
end
