class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :longitude, :latitude, :name, :street, :zip_code, :address

  def address
    if object.is_home?
      object.street
    else
      object.address
    end
  end
end
