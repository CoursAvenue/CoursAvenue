class BookTicket < ActiveRecord::Base
  belongs_to :course

  attr_accessible :number, :price, :validity # in months

  validates :number, presence: true

  def price
    if read_attribute(:price).nil?
      ''
    else
      ('%.2f' % read_attribute(:price)).gsub('.00', '')
    end
  end

end
