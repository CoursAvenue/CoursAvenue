class Price::PremiumOffer < Price
  # Price libelle
  #   prices.premium_offer.discount: Réduction
  #   prices.premium_offer.discover: Tarif découverte
  #   prices.premium_offer.other: Autre offre

  attr_accessible :promo_amount, :info, :promo_amount_type # '%' or '€'

  validates :promo_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :presence_of_mandatory_fields

  TYPES = ['prices.premium_offer.discount',
           'prices.premium_offer.discover',
           'prices.premium_offer.other']

  # If users removes promo_amount, then reject price
  def has_to_be_rejected?
    self.promo_amount.blank? and self.info.blank?
  end

  def free?
    self.promo_amount == 0
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
