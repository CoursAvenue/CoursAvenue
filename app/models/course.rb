class Course < ActiveRecord::Base
  belongs_to :structure

  has_and_belongs_to_many :audiences
  has_and_belongs_to_many :levels

  belongs_to :discipline

  has_one :price
  has_one :planning

  attr_accessible :lesson_info_1, :lesson_info_2, :max_age_for_kid, :min_age_for_kid, :is_individual

end
