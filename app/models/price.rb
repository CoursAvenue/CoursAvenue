class Price < ActiveRecord::Base
  belongs_to :course

  attr_accessible :libelle,
                  :amount

  def libelle
    I18n.t read_attribute(:libelle)
  end

  def readable_amount
    if read_attribute(:amount).nil?
      nil
    else
      ('%.2f' % read_attribute(:amount)).gsub('.', ',').gsub(',00', '')
    end
  end

  def readable_amount_with_promo
    price_with_promo = read_attribute(:amount) + (read_attribute(:amount) * course.promotion / 100)
    ('%.2f' % price_with_promo).gsub('.', ',').gsub(',00', '')
  end

end
