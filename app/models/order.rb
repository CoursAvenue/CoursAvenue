class Order < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :type, :order_id, :amount, :structure, :subscription_plan, :promotion_code_id

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  validates :order_id, uniqueness: { scope: :type }

end
