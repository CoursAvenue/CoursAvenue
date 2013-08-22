class Price < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :course

  before_validation :update_nb_courses

  # Possible libelle:
  #   prices.free: Gratuit
  #   prices.contact_structure: Contacter l'établissement
  #   prices.individual_course: Cours seul

  attr_accessible :libelle,
                  :amount,
                  :promo_amount,
                  :nb_courses,
                  :info,
                  :course

  validates :libelle      , uniqueness: {scope: 'course_id'}
  validates :amount       , presence: true
  validates :amount       , numericality: { greater_than_or_equal_to:  0 }
  validates :promo_amount , numericality: { less_than: :amount }, allow_nil: true

  scope :book_tickets , where(type: 'Price::BookTicket')
  scope :subscriptions, where(type: 'Price::Subscription')
  scope :registrations, where(type: 'Price::Registration')
  scope :discounts    , where(type: 'Price::Discount')

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
    when 'prices.subscription.annual'
      self.nb_courses = 35
    when 'prices.subscription.semester'
      self.nb_courses = 17
    when 'prices.subscription.trimester'
      self.nb_courses = 11
    when 'prices.subscription.month'
      self.nb_courses = 4
    when 'prices.trial_lesson'
      self.nb_courses = 1
    else
      self.nb_courses = 0
    end
  end
end
