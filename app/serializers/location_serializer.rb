class LocationSerializer < ActiveModel::Serializer
  attributes :id, :longitude, :latitude, :name, :street, :zip_code

end
