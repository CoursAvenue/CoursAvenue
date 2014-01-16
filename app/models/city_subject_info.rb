class CitySubjectInfo < ActiveRecord::Base
  belongs_to :city
  belongs_to :subject

  attr_accessible :title, :description, :city_id, :subject_id,
                  :where_to_practice, :where_to_suit_up, :average_price, :tips

end
