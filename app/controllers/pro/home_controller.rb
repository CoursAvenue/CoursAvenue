class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def index
    @admin      = ::Admin.new
    latitude, longitude, radius = 48.8540, 2.3417, 5
    @structures = StructureSearch.search({lat: latitude,
                                          lng: longitude,
                                          radius: radius,
                                          sort: 'rating_desc',
                                          has_logo: true,
                                          per_page: 50,
                                          bbox: true
                                        }).results
    @locations = []
    @structures.each do |structure|
      @locations += structure.locations_around(latitude, longitude, radius)
    end

    @json_locations_addresses = Gmaps4rails.build_markers(@locations) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end
  end

  def presentation
  end

  def price
    @email = ::Email.new
  end

  def press
  end
end
