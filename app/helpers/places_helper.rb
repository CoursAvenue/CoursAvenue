module PlacesHelper
  def short_address(place)
    "#{place.city.name} #{place.zip_code[3..5]}"
  end
  def readable_address(place)
    "#{place.street}, #{place.zip_code}, Paris"
  end
end
