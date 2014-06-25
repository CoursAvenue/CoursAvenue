class Subjects::CitiesController < ApplicationController
  def show
    @city    = City.find params[:id]
    @subject = Subject.find params[:subject_id]

    if @subject.depth == 1
      to_merge = { subject_slugs: @subject.children.map(&:slug) }
    else
      to_merge = { subject_id: @subject.slug }
    end

    @structure_search            = StructureSearch.search({ lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 20, bbox: true }.merge(to_merge))
    @location_search             = LocationSearch.search({ lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 80, bbox: true }.merge(to_merge))
    @planning_search             = PlanningSearch.search({ lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true }.merge(to_merge))
    @free_trial_plannings_search = PlanningSearch.search({ lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true, trial_course_amount: 0 }.merge(to_merge))
    @medias_search               = MediaSearch.search({ lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true }.merge(to_merge))
    @images_search               = MediaSearch.search({ lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 25, type: 'Media::Image', bbox: true }.merge(to_merge))
    @comments_search             = CommentSearch.search({ lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 25, has_title: true, bbox: true }.merge(to_merge))

    if @subject.depth > 1
      @videos_search            = MediaSearch.search({ lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 5, type: 'Media::Video', bbox: true }.merge(to_merge))
      @videos                   = @videos_search.results
    end

    @city_subject_info        = CitySubjectInfo.load(@city.id, @subject.id)

    @structures_count         = @structure_search.total
    @places_count             = @location_search.total
    @plannings_count          = @planning_search.total
    @free_trial_course_count  = @free_trial_plannings_search.total
    @comments_count           = @comments_search.total
    @medias_count             = @medias_search.total

    @city_latlng = Gmaps4rails.build_markers(@city) do |city, marker|
      marker.lat city.latitude
      marker.lng city.longitude
    end
  end
end
