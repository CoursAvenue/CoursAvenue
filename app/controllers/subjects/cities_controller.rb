class Subjects::CitiesController < ApplicationController

  def show
    @subject          = Subject.friendly.find params[:subject_id]
    @city             = City.friendly.find params[:id]
    @structure_search = StructureSearch.search({lat: @city.latitude,
                                          lng: @city.longitude,
                                          radius: 4,
                                          sort: 'rating_desc',
                                          has_logo: true,
                                          per_page: 150,
                                          subject_id: @subject.slug
                                        })

    @structures = @structure_search.results
    @locations  = @structures.map{|s| s.locations_around(@city.latitude, @city.longitude, 4) }

    @plannings = @structures.map{|structure| structure.courses.map(&:plannings).flatten}.flatten

    @medias     = @structures.collect(&:medias).flatten

    @json_structure_addresses = @locations.flatten.to_gmaps4rails do |location, marker|
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image disabled' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'></a></div>"
                     })
      marker.title   location.name
      marker.json({
        id: location.id,
        structure_slug: location.structures.first.slug
      })
    end

  end
end
