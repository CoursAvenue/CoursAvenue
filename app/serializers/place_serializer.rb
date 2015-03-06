class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :longitude, :latitude, :name, :street, :zip_code, :address, :structure_id

  # cached
  # delegate :cache_key, to: :object

  def address
    if object.is_home?
      object.street
    else
      object.address
    end
  end
end
