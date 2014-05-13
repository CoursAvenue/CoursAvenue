# encoding: utf-8
class ::Price::BookTicket < Price

  attr_accessible :number, :duration # in minutes

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :number, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false
  validates :promo_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate  :promo_amount_less_than_amount
  validate  :amount_has_to_be_filled_if_promo_amount

  def book_ticket?
    true
  end

  def per_course_amount
    self.amount / self.number
  end

  def per_course_promo_amount
    self.promo_amount / self.number
  end

  def localized_libelle
    if number == 1
      I18n.t('prices.individual_course')
    else
      I18n.t('prices.book_ticket.libelle', count: number)
    end
  end

  def has_promo?
    !promo_amount.nil?
  end

  def readable_amount_with_promo
    amount_with_promo = read_attribute(:amount) + (read_attribute(:amount) * course.promotion / 100)
    ('%.2f' % amount_with_promo).gsub('.', ',').gsub(',00', '')
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
