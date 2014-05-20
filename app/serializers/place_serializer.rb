class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :longitude, :latitude, :name, :street, :zip_code, :address

  def address
    object.address
  end
end
