class Cities::SubjectsController < ApplicationController

  def show
    @city    = City.find params[:city_id]
    @subject = Subject.find params[:id]

    if @subject.depth == 1
      to_merge = { subject_slugs: @subject.children.map(&:slug) }
    else
      to_merge = { subject_id: @subject.slug }
    end

    @structure_search            = StructureSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 6, bbox: true}.merge(to_merge))
    @location_search             = LocationSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 80, bbox: true}.merge(to_merge))
    @planning_search             = PlanningSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true}.merge(to_merge))
    @free_trial_plannings_search = PlanningSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true, trial_course_amount: 0}.merge(to_merge))
    @medias_search               = MediaSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 25, bbox: true}.merge(to_merge))
    @comments_search             = CommentSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 25, bbox: true}.merge(to_merge))
    @courses_search              = CourseSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true}.merge(to_merge))

    @structures               = @structure_search.results
    @medias                   = @medias_search.results
    @courses                  = @courses_search.results

    @structures_count         = @structure_search.total
    @places_count             = @location_search.total
    @plannings_count          = @planning_search.total
    @free_trial_course_count  = @free_trial_plannings_search.total
    @comments_count           = @comments_search.total
    @medias_count             = @medias_search.total

    @json_structure_addresses = Gmaps4rails.build_markers(@location_search.results) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end
  end
end
