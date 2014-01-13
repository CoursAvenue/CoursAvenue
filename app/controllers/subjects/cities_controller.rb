class Subjects::CitiesController < ApplicationController

  def show
    @subject          = Subject.friendly.find params[:subject_id]
    @city             = City.friendly.find params[:id]
    if @subject.depth == 1
      descendants_slugs = @subject.children.map(&:slug)
      to_merge = {subject_slugs: descendants_slugs}
    else
      to_merge = {subject_id: @subject.slug}
    end
    @structure_search = StructureSearch.search({lat: @city.latitude,
                                                lng: @city.longitude,
                                                radius: 4,
                                                sort: 'rating_desc',
                                                has_logo: true,
                                                per_page: 150
                                              }.merge(to_merge))

    @structures = @structure_search.results
    @locations  = @structures.map{|s| s.locations_around(@city.latitude, @city.longitude, 4) }

    @courses   = CourseSearch.search({lat: @city.latitude,
                                      lng: @city.longitude,
                                      radius: 4,
                                      per_page: 150,
                                      subject_id: @subject.slug
                                    }).results
    @plannings = @courses.map(&:plannings).flatten

    @medias     = @structures.collect(&:medias).flatten

    if @locations.empty?
      @locations << Location.new(latitude: @city.latitude, longitude: @city.longitude)
    end
    @json_structure_addresses = Gmaps4rails.build_markers(@locations.flatten) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end
  end
end

