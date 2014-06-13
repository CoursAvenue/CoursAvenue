class Order < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :structure
  belongs_to :subscription_plan

  attr_accessible :order_id, :amount, :structure, :subscription_plan

  validates :order_id, uniqueness: true

  def self.next_order_id_for(structure)
    "PREMIUM_#{I18n.l(Date.today)}_#{structure.orders.count + 1}"
  end
end
