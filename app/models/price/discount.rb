class Price::Discount < Price
  # Price libelle
  #   prices.discount.student: Étudiant
  #   prices.discount.young_and_senior: Jeune et sénior
  #   prices.discount.job_seeker: Au chômage
  #   prices.discount.low_income: Revenu faible
  #   prices.discount.large_family: Famille nombreuse
  #   prices.discount.couple: Couple
  attr_accessible :promo_percentage
  validates :promo_percentage, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  TYPES = ['prices.discount.student',
           'prices.discount.young_and_senior',
           'prices.discount.job_seeker',
           'prices.discount.low_income',
           'prices.discount.large_family',
           'prices.discount.couple',
           'prices.discount.other']

  def discount?
    true
  end
end
