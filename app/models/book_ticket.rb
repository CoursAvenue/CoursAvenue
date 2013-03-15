class BookTicket < ActiveRecord::Base
  belongs_to :course

  attr_accessible :number, :price, :validity # in months

  validates :number, presence: true
  validates :price, presence: true

  def readable_price
    if read_attribute(:price).nil?
      ''
    else
      ('%.2f' % read_attribute(:price)).gsub('.', ',').gsub(',00', '')
    end
  end

  def readable_price_with_promo
    price_with_promo = read_attribute(:price) + (read_attribute(:price) * course.promotion / 100)
    ('%.2f' % price_with_promo).gsub('.', ',').gsub(',00', '')
  end
end
