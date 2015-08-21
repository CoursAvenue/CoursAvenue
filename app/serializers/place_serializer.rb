class PlaceSerializer < ActiveModel::Serializer

  cached
  def cache_key
    'PlaceSerializer/' + object.cache_key
  end

  attributes :id, :longitude, :latitude, :name, :street, :zip_code, :address, :structure_id

  def address
    if object.is_home?
      object.street
    else
      object.address
    end
  end
end
