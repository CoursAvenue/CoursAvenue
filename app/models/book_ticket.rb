class BookTicket < ActiveRecord::Base
  belongs_to :course_group

  attr_accessible :number, :price, :validity
end
