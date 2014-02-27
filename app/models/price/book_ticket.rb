# encoding: utf-8
class ::Price::BookTicket < Price

  attr_accessible :number # in minutes

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :number, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false

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
end
