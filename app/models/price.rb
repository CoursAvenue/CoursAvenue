class Price < ActiveRecord::Base
  belongs_to :course

  attr_accessible :libelle,
                  :amount

  def libelle
    I18n.t read_attribute(:libelle)
  end

  def amount
    ('%.2f' % read_attribute(:amount)).gsub('.', ',').gsub(',00', '')
  end

end
