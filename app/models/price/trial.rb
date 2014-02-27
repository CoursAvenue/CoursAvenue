class Price::Trial < Price
  # Price libelle
  # libelle = prices.discount.trial_lesson
  after_initialize :set_libelle
  before_save      :set_libelle

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false

  def set_libelle
    self.libelle = 'prices.discount.trial_lesson'
  end

  def free?
    amount == 0
  end

  def trial?
    true
  end
end
