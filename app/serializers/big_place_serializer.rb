class BigPlaceSerializer < ActiveModel::Serializer

  has_one :location
  has_many :contacts

end
