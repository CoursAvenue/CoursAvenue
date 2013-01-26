class RegistrationFee < ActiveRecord::Base
  belongs_to :course

  attr_accessible :for_kid, :price

  def price
    ('%.2f' % read_attribute(:price)).gsub('.00', '')
  end
end
