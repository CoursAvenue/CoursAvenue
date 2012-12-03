# CourseGroups are grouped by same name, audiences and levels
class CourseGroup < ActiveRecord::Base
  # For pagination
  self.per_page = 15

  belongs_to :structure

  has_many :courses  , dependent: :destroy

  has_many :plannings, through: :courses
  has_many :prices   , through: :courses

  has_and_belongs_to_many :audiences
  has_and_belongs_to_many :levels

  belongs_to :discipline

  attr_accessible :name

  def is_lesson?
    false
  end

  def is_training?
    false
  end

end
