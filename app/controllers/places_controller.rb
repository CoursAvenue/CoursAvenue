# encoding: utf-8
class PlacesController < ApplicationController

  def add_user
    @place = Place.find(params[:id])
    current_user.places << @place
    current_user.save
    respond_to do |format|
      format.html { redirect_to place_path(@place), notice: 'Vous suivez cet établissement'}
    end
  end

  def remove_user
    @place = Place.find(params[:id])
    current_user.places.delete @place
    current_user.save
    respond_to do |format|
      format.html { redirect_to place_path(@place), notice: 'Vous ne suivez plus cet établissement'}
    end
  end

  def index
    cookies[:place_search_path] = request.fullpath

    if params[:subject_id]
      @subject = Subject.find params[:subject_id]
    end

    @places = PlaceSearch.search(params)
    init_geoloc

    # fresh_when etag: [@places, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

  def show
    if request.subdomain == 'pro'
      redirect_to place_url params[:id], subdomain: 'www', status: 301
    end
    @place     = Place.find params[:id]
    @structure = @place.structure
    @courses   = @place.courses.order('name ASC')
    @teachers  = @structure.teachers
    @comments  = @structure.all_comments
    @comment   = @structure.comments.build
    @city      = @place.city
    @medias    = @structure.medias
    place           = @place
    place_latitude  = @place.latitude
    place_longitude = @place.longitude

    search_params = {per_page: 5, radius: 4}
    if place.is_geolocalized?
      search_params[:lat] = place.latitude
      search_params[:lng] = place.longitude
    end
    # @surrounding_places = PlaceSearch.search(search_params)

    @json_place_address = @place.to_gmaps4rails do |place, marker|
      marker.title   place.name
      marker.json({ id: place.id })
    end

    # fresh_when etag: [@place, @comments.first, ENV["ETAG_VERSION_ID"]], public: true
    # fresh_when etag: @place, last_modified: @place.updated_at # Tell the page is new
    # Can pass in an array [@place, @comments]
    # If add respond_to :
    # if stale? etag: @place
    #   respond_to do |format|...
    #     ...
    #   end
    # end
  end

  private

  def init_geoloc
    place_index = 0
    @json_place_addresses = @places.to_gmaps4rails do |place, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='#'><span>#{place_index}</span></a></div>"
                     })
      marker.title   place.name
      marker.json({ id: place.id })
    end
  end
end
