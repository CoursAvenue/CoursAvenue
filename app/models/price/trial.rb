class Price::Trial < Price
  # Price libelle
  # libelle = prices.discount.trial_lesson
  after_initialize :set_libelle

  def set_libelle
    libelle = 'prices.discount.trial_lesson'
  end

  def free?
    amount == 0
  end
end
