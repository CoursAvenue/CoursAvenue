class Price < ActiveRecord::Base
  belongs_to :course_group
  attr_accessible :libelle,
                  :amount

  validates :libelle, :uniqueness => true

  def libelle
    I18n.t read_attribute(:libelle)
  end

  def amount
    '%.2f' % read_attribute(:amount)
  end

end
