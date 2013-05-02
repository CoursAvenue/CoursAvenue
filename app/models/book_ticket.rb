# encoding: utf-8
class BookTicket < ActiveRecord::Base
  belongs_to :course

  attr_accessible :number, :amount, :promo_amount, :validity # in months

  validates :number, presence: true
  validates :amount, presence: true

  def libelle
    if validity
      "Carnet de #{number} cours (validité #{validity.to_i} mois)"
    else
      "Carnet de #{number} cours"
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
