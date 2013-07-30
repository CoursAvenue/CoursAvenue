class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def index
    @admin      = ::Admin.new
    # @structures = Structure.where{(image_updated_at != nil) & (comments_count != nil)}.order('comments_count DESC').limit(5)
    # @places     = @structures.collect{ |s| s.places.first }
    @places     = PlaceSearch.search({lat: 48.8540,
                                      lng: 2.3417,
                                      radius: 8,
                                      per_page: 1000,
                                      sort: 'rating_desc',
                                      has_picture: true,
                                      per_page: 16
                                    })
    @places = @places.collect{|p| p.structure.places.first }.uniq
    place_index = 0
    @json_places_addresses = @places.to_gmaps4rails do |place, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'><span>#{place_index}</span></a></div>"
                     })
      marker.title   place.long_name
      marker.json({ id: place.id })
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
