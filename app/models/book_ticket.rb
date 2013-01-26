class BookTicket < ActiveRecord::Base
  belongs_to :course

  attr_accessible :number, :price, :validity # in months

  validates :number, :price, :validity, presence: true

  def price
    ('%.2f' % read_attribute(:price)).gsub('.00', '')
  end

end
