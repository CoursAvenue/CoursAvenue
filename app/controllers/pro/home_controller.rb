class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def index
    @admin      = ::Admin.new
    @structures = StructureSearch.search({lat: 48.8540,
                                          lng: 2.3417,
                                          radius: 3,
                                          per_page: 1000,
                                          sort: 'rating_desc',
                                          has_logo: true,
                                          per_page: 15
                                        })
    @locations     = @structures.collect{|structure| structure.locations.first }.uniq
    location_index = 0
    @json_locations_addresses = @locations.to_gmaps4rails do |location, marker|
      location_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image disabled' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'><span>#{location_index}</span></a></div>"
                     })
      marker.title   location.name
      marker.json({ id: location.id })
    end
  end

  def presentation
  end

  def price
    @admin = ::Admin.new
  end

  def press
  end
end
