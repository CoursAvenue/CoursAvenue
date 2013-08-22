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
end
