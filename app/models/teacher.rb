class Teacher < ActiveRecord::Base
  belongs_to :structure
  has_many   :plannings
  has_many   :courses, through: :plannings
  attr_accessible :name, :description, :structure_id

  validates :name, presence: true

  default_scope order('name ASC')
end
