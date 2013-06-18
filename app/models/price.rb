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

  validates :libelle      , uniqueness: {scope: 'course_id'}
  validates :amount       , presence: true
  validates :amount       , numericality: { greater_than_or_equal_to:  0 }
  validates :promo_amount , numericality: { less_than: :amount }, allow_nil: true

  def per_course_amount
    return nil if amount.nil?
    amount / self.nb_courses
  end

  def per_course_promo_amount
    return nil if promo_amount.nil?
    self.nb_courses
    promo_amount / self.nb_courses
  end

  def individual_course?
    libelle == 'prices.individual_course'
  end

  def has_promo?
    !promo_amount.nil?
  end

  def nb_courses
    return 1 if read_attribute(:nb_courses).nil?
    read_attribute(:nb_courses)
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
