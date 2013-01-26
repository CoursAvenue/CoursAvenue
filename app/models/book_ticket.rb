class BookTicket < ActiveRecord::Base
  belongs_to :course

  attr_accessible :number, :price, :validity # in months

  validates :number, :price, :validity, presence: true

end
