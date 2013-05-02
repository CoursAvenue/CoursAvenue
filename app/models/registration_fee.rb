class RegistrationFee < ActiveRecord::Base
  belongs_to :course

  attr_accessible :for_kid, :amount

  def price
    ('%.2f' % read_attribute(:price)).gsub('.00', '')
  end
end
