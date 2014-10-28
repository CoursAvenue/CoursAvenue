class Order::Premium < Order

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to   :structure
  belongs_to   :subscription_plan
  belongs_to   :promotion_code

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :increment_promotion_code_nb

  validates :structure, :subscription_plan, presence: true

  def self.next_order_id_for(structure)
    order_number = structure.orders.count + 1
    "FR#{Date.today.year}#{structure.id}#{order_number}"
  end

  def public_order_id
    order_number = self.structure.orders.index(self) + 1
    "FR#{Date.today.year}#{structure.id}#{order_number}"
  end

  def amount
    if self.promotion_code
      self.amount_without_promo - self.promotion_code.promo_amount
    else
      self.amount_without_promo
    end
  end

  def amount_without_promo
    read_attribute(:amount)
  end

  private

  # Increment promotion code usage_nb
  #
  # @return nil
  def increment_promotion_code_nb
    self.promotion_code.increment! if self.promotion_code
    nil
  end
end
