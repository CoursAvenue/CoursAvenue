class BookTicket < ActiveRecord::Base
  belongs_to :course_group

  attr_accessible :number, :price, :validity # in months

  validates :number, :price, :validity, presence: true

end
