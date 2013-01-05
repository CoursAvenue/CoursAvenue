class BookTicket < ActiveRecord::Base
  belongs_to :course

  attr_accessible :number, :price, :validity
end
