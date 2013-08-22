class Price::Discount < Price
  # Price libelle
  #   prices.discount.student: Étudiant
  #   prices.discount.young_and_senior: Jeune et sénior
  #   prices.discount.job_seeker: Au chômage
  #   prices.discount.low_income: Revenu faible
  #   prices.discount.large_family: Famille nombreuse
  #   prices.discount.couple: Couple
  #   prices.discount.trial_lesson: Cours d'essai

  TYPES = ['prices.discount.student',
           'prices.discount.young_and_senior',
           'prices.discount.job_seeker',
           'prices.discount.low_income',
           'prices.discount.large_family',
           'prices.discount.couple',
           'prices.discount.trial_lesson']
end


