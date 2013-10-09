class LocationSerializer < ActiveModel::Serializer
  attributes :id, :longitude, :latitude, :name, :street, :zip_code
  has_many :places

end
