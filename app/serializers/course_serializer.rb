class CourseSerializer < ActiveModel::Serializer
  attributes :id

  has_many :courses
  has_many :plannings
  has_many :prices
  has_many :book_tickets

end
