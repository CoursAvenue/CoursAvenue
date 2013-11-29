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
                                          per_page: 100,
                                          bbox: true
                                        }).results
    @locations = []
    @structures.each do |structure|
      @locations += structure.locations_around(latitude, longitude, radius)
    end
    @json_locations_addresses = @locations.to_gmaps4rails do |location, marker|
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image disabled'><a href='javascript:void(0)'></a></div>"
                     })
      marker.title   location.name
      marker.json({ id: location.id })
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
