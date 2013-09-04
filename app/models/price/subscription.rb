class Price::Subscription < Price
  # Price libelle
  #   prices.subscription.annual: Abonnement annuel
  #   prices.subscription.semester: Abonnement semestriel
  #   prices.subscription.trimester: Abonnement trimestriel
  #   prices.subscription.month: Abonnement mensuel
  TYPES = ['prices.subscription.annual',
           'prices.subscription.semester',
           'prices.subscription.trimester',
           'prices.subscription.month']

  TYPES_ORDER = { 'prices.subscription.annual'    => 1,
                  'prices.subscription.semester'  => 2,
                  'prices.subscription.trimester' => 3,
                  'prices.subscription.month'     => 4
                }

  def subscription?
    true
  end
end
