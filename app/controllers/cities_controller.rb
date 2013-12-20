class CitiesController < ApplicationController

  require 'wikipedia'

  def show
    @city = City.friendly.find(params[:id])
    @structure_search            = StructureSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true})
    @location_search             = LocationSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true})
    @planning_search             = PlanningSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true})
    @free_trial_plannings_search = PlanningSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true, trial_course_amount: 0})
    @medias_search               = MediaSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true})
    @comments_search             = CommentSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true})

    @structures_count         = @structure_search.total
    @places_count             = @location_search.total
    @plannings_count          = @planning_search.total
    @free_trial_course_count  = @free_trial_plannings_search.total
    @comments_count           = @comments_search.total
    @medias_count             = @medias_search.total

    if @city.image?
      @city_image = @city.image
    else
      page = Wikipedia.find( @city.name )
      @city_image = page.image_urls.first
    end

    @city_latlng = Gmaps4rails.build_markers(@city) do |city, marker|
      marker.lat city.latitude
      marker.lng city.longitude
    end

  end

  def zip_code_search
    term = params[:term]
    @cities = City.where{zip_code =~ term}.limit(20)

    respond_to do |format|
      format.json { render json: @cities }
    end
  end
end
