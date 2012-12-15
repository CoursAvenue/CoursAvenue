class CourseGroupSerializer < ActiveModel::Serializer
  attributes :id

  has_many :courses
  has_many :plannings
  has_many :prices

end
