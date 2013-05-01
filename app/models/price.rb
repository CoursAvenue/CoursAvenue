class Price < ActiveRecord::Base
  belongs_to :course

  before_validation :update_nb_courses

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
                  :promo_amount,
                  :nb_courses

  validates :libelle, uniqueness: {scope: 'course_id'}
  validates :amount , presence: true

  def per_course_amount
    if amount.nil?
      nil
    else
      nb_courses ||= 1
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

  def individual_course?
    libelle == 'prices.individual_course'
  end

  private

  def update_nb_courses
    case libelle
    when 'prices.free'
      self.nb_courses = 1
    when 'prices.individual_course'
      self.nb_courses = 1
    when 'prices.two_lesson_per_week_package'
      self.nb_courses = 2
    when 'prices.annual'
      self.nb_courses = 35
    when 'prices.semester'
      self.nb_courses = 17
    when 'prices.trimester'
      self.nb_courses = 11
    when 'prices.month'
      self.nb_courses = 4
    when 'prices.trial_lesson'
      self.nb_courses = 1
    when 'prices.training'
      self.nb_courses = 1
    else
      self.nb_courses = 0
    end
  end
end
