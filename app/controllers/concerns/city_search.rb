module CitySearch
  extend ActiveSupport::Concern

  def cities_from_zip_code zip_code
    @cities = Sunspot.search(City) do
      with(:zip_codes).any_of [zip_code]
    end.results
  end
end
