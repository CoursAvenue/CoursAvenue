class CitySubjectInfo < ActiveRecord::Base
  belongs_to :city
  belongs_to :subject

  attr_accessible :title, :description, :city_id, :subject_id

end
