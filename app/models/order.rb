class Order < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :structure
  belongs_to :subscription_plan

  attr_accessible :order_id, :amount, :structure, :subscription_plan

  validates :order_id, uniqueness: true

  def self.next_order_id_for(structure)
    "#{structure.id}_#{I18n.l(Date.today)}__#{structure.orders.count + 1}"
  end

  def public_order_id
    order_number = self.structure.orders.index(self) + 1
    "FR#{Date.today.year}#{structure.id}#{order_number}"
  end
end
