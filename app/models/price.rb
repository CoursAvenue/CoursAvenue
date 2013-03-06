class Price < ActiveRecord::Base
  belongs_to :course

  # Possible libelle:
  #   prices.free: Gratuit
  #   prices.contact_structure: Contacter l'établissement
  #   prices.individual_course: Cours seul
  #   prices.annual: Abonnement annuel
  #   prices.two_lesson_per_week_package: Forfait deux cours par semaine
  #   prices.semester: Abonnement semestriel
  #   prices.trimester: Abonnement trimestriel
  #   prices.month: Abonnement mensuel
  #   prices.student: Étudiant
  #   prices.young_and_senior: Jeune et sénior
  #   prices.job_seeker: Au chômage
  #   prices.low_income: Revenu faible
  #   prices.large_family: Famille nombreuse
  #   prices.couple: Couple
  #   prices.trial_lesson: Cours d'essai
  #   prices.training: Prix du stage

  attr_accessible :libelle,
                  :amount,
                  :nb_courses

  def per_course_amount
    if amount.nil?
      nil
    else
      ('%.2f' % (amount / nb_courses)).gsub('.', ',').gsub(',00', '')
    end
  end

  def readable_amount
    if amount.nil?
      nil
    else
      ('%.2f' % amount).gsub('.', ',').gsub(',00', '')
    end
  end

  def readable_amount_with_promo
    price_with_promo = amount + (amount * course.promotion / 100)
    ('%.2f' % price_with_promo).gsub('.', ',').gsub(',00', '')
  end

end
