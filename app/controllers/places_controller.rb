# encoding: utf-8
class PlacesController < ApplicationController

  before_filter :prepare_search, only: [:show, :index]

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
    @search = Sunspot.search(Place) do
      fulltext                     params[:name]         if params[:name].present?
      with(:subject_slugs).any_of [params[:subject_id]]  if params[:subject_id]

      with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 10, :bbox => true)

      with :active,  true

      if params[:sort] == 'rating_desc'
        order_by :rating, :desc
        order_by :nb_comments, :desc
      else
        order_by :nb_courses, :desc
        order_by :has_comment, :desc
        order_by_geodist(:location, params[:lat], params[:lng])
      end
      paginate :page => (params[:page] || 1), :per_page => 15
    end
    @places = @search.results

    init_geoloc

    # fresh_when etag: [@places, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

  def show
    @place     = Place.find params[:id]
    @structure = @place.structure
    @courses   = @place.courses.active
    @comments  = @structure.all_comments
    @comment   = @structure.comments.build
    @city      = @place.city

    place_latitude  = @place.latitude
    place_longitude = @place.longitude
    @search = Sunspot.search(Place) do
      with(:location).in_radius(place_latitude, place_longitude, params[:radius] || 10, :bbox => true)
      without(:street, nil)
      paginate :page => (1), :per_page => 5
    end
    @surrounding_places = @search.results

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

  def prepare_search
    if params[:lat].blank? or params[:lng].blank?
      if request.location and request.location.longitude != 0 and request.location.latitude != 0
        params[:lat] = request.location.latitude
        params[:lng] = request.location.longitude
      else
        # Setting paris lat & lng per default
        params[:lat] = 48.8592
        params[:lng] = 2.3417
      end
    end
  end
end
