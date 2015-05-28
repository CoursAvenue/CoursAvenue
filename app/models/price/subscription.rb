class Price::Subscription < Price

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false
  validates :promo_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate  :promo_amount_less_than_amount
  validate  :amount_has_to_be_filled_if_promo_amount

  # Price libelle

  TYPES = ['prices.subscription.annual',    # Abonnement annuel
           'prices.subscription.semester',  # Abonnement semestriel
           'prices.subscription.trimester', # Abonnement trimestriel
           'prices.subscription.month',     # Abonnement mensuel
           'prices.subscription.other']     # Autre

  TYPES_ORDER = { 'prices.subscription.other'    => 5,
                  'prices.subscription.annual'    => 4,
                  'prices.subscription.semester'  => 3,
                  'prices.subscription.trimester' => 2,
                  'prices.subscription.month'     => 1
                }

  def subscription?
    true
  end

  # Reject price if both amount AND promo_amount are blank
  def has_to_be_rejected?
    self.amount.blank? and self.promo_amount.blank?
  end

  private

  # If a promo amount is filled, the amount also have to be filled
  def amount_has_to_be_filled_if_promo_amount
    if promo_amount.present? and amount.blank?
      self.errors.add :amount, :blank
    end
  end

  # The promo amount HAS to be LESS THAN the default amount
  def promo_amount_less_than_amount
    if amount and promo_amount and promo_amount >= amount
      self.errors.add :promo_amount, I18n.t('prices.errors.promo_amount_less_than_promo')
    end
  end
end
