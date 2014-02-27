class Price::Subscription < Price

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false

  # Price libelle
  #   prices.subscription.annual: Abonnement annuel
  #   prices.subscription.semester: Abonnement semestriel
  #   prices.subscription.trimester: Abonnement trimestriel
  #   prices.subscription.month: Abonnement mensuel

  TYPES = ['prices.subscription.annual',
           'prices.subscription.semester',
           'prices.subscription.trimester',
           'prices.subscription.month']

  TYPES_ORDER = { 'prices.subscription.annual'    => 4,
                  'prices.subscription.semester'  => 3,
                  'prices.subscription.trimester' => 2,
                  'prices.subscription.month'     => 1
                }

  def subscription?
    true
  end
end
