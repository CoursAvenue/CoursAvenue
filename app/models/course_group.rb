class CourseGroup < ActiveRecord::Base
  # For pagination
  self.per_page = 20

  belongs_to :structure

  has_and_belongs_to_many :audiences
  has_and_belongs_to_many :levels

  belongs_to :discipline

  attr_accessible :name

  def is_lesson?
    false
  end

  def is_workshop?
    false
  end

  def is_training?
    false
  end

end
