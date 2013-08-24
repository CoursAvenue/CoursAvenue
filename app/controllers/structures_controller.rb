# encoding: utf-8
class StructuresController < ApplicationController
  respond_to :json

  def recommendation
    recommendation = '<p>' + params[:recommendation].gsub(/\r\n/, '</p><p>') + '</p>'
    name           = params[:name]
    email          = params[:email]
    StudentMailer.recommend_structure(name, email, recommendation)
    respond_to do |format|
      format.html { redirect_to request.referrer, notice: "Merci pour votre aide, nous allons contacter l'établissement au plus vite !"}
    end
  end

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
    @places_address = @structure.locations.to_gmaps4rails
    @courses        = @structure.courses.active
    @teachers       = @structure.teachers
    @medias         = @structure.medias
    @comments       = @structure.all_comments
    @comment        = @structure.comments.build
  end

  def index

    if params[:subject_id]
      @subject = Subject.find params[:subject_id]
    end

    @structures = StructureSearch.search(params)
    init_geoloc

    respond_to do |format|
      format.json { render json: @structures.to_json(include: [:city]) }
      format.html do
        cookies[:structure_search_path] = request.fullpath
      end
    end
    # fresh_when etag: [@places, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

  private

  def init_geoloc
    latitude             = params[:lat].to_f
    longitude            = params[:lng].to_f
    radius               = (params[:radius] || 5).to_f
    @locations           = []
    @structure_locations = {} # Keeping in memory only locations that are in the radius
    @structures.each do |structure|
      @structure_locations[structure] = structure.locations_around(latitude, longitude, radius)
      @locations += @structure_locations[structure]
    end
    place_index = 0
    @json_structure_addresses = @locations.uniq.to_gmaps4rails do |location, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'><span>#{place_index}</span></a></div>"
                     })
      marker.title   location.name
      marker.json({ id: location.id })
    end
  end
end
