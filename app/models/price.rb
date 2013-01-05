class Price < ActiveRecord::Base
  belongs_to :course

  attr_accessible :libelle,
                  :amount

  def libelle
    I18n.t read_attribute(:libelle)
  end

end
