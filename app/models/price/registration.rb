class Price::Registration < Price

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false

  def registration?
    true
  end

  def free?
    amount == 0
  end

  def libelle
    'prices.registration_fees'
  end
end
