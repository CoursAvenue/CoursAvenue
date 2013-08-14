# encoding: utf-8
class StructuresController < ApplicationController

  def show
    begin
      @structure = Structure.find params[:id]
    rescue ActiveRecord::RecordNotFound
      place = Place.find params[:id]
      redirect_to structure_path(place.structure), status: 301
      return
    end
    @city           = @structure.city
    @places         = @structure.places
    @places_address = @places.to_gmaps4rails
    @courses        = @structure.courses.active
    @teachers       = @structure.teachers
    @medias         = @structure.medias
    @comments       = @structure.all_comments
    @comment        = @structure.comments.build
    HA?
  end

  def index
    cookies[:place_search_path] = request.fullpath

    if params[:subject_id]
      @subject = Subject.find params[:subject_id]
    end

    @structures = StructureSearch.search(params)
    init_geoloc

    # fresh_when etag: [@places, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

  private

  def init_geoloc
    places      = []
    place_index = {}
    latitude    = params[:lat].to_f
    longitude   = params[:lng].to_f
    radius      = (params[:radius] || 5).to_f
    @structure_places = {}
    @locations = []
    @structures.each do |structure|
      @structure_places[structure] = structure.places.reject do |place|
        # place_index[place.id] = structure_index
        Geocoder::Calculations.distance_between([latitude, longitude], [place.latitude, place.longitude], unit: :km) > radius
      end
      places += @structure_places[structure]
    end
    index = 0
    place_index = 0
    @json_structure_addresses = places.to_gmaps4rails do |place, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'><span>#{place_index}</span></a></div>"
                     })
      marker.title   place.name
      marker.json({ id: place.structure_id })
    end
  end
end
