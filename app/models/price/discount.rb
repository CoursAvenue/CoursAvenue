class Price::Discount < Price
  # Price libelle
  #   prices.discount.student: Étudiant
  #   prices.discount.young_and_senior: Jeune et sénior
  #   prices.discount.job_seeker: Au chômage
  #   prices.discount.low_income: Revenu faible
  #   prices.discount.large_family: Famille nombreuse
  #   prices.discount.couple: Couple

  attr_accessible :promo_amount, :info, :promo_amount_type # '%' or '€'

  validates :promo_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :presence_of_mandatory_fields

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

  def has_to_be_rejected?
    self.promo_amount.blank?
  end

  private


  # Adds error to base if there is no promo_amount neither description
  #
  # @return nothing
  def presence_of_mandatory_fields
    if promo_amount.blank? and info.blank?
      errors[:base] << 'Au moins un des champs doivent être remplis'
    end
  end
end
