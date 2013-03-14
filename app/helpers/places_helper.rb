module PlacesHelper
  def short_address(place)
    "#{place.city.name}"
  end
  def readable_address(place)
    "#{place.street}, #{place.zip_code}, Paris"
  end
end
