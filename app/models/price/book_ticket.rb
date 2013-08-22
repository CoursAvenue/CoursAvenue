# encoding: utf-8
class Price::BookTicket < Price

  attr_accessible :number

  validates :number, presence: true

  def libelle
    "Carnet de #{number} cours"
  end

  def has_promo?
    !promo_amount.nil?
  end


  def readable_amount_with_promo
    amount_with_promo = read_attribute(:amount) + (read_attribute(:amount) * course.promotion / 100)
    ('%.2f' % amount_with_promo).gsub('.', ',').gsub(',00', '')
  end
end
