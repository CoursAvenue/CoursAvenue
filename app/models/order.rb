class Order < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :type, :order_id, :amount

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  validates :order_id, uniqueness: { scope: :type }

end
