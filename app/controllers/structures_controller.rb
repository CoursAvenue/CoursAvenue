# encoding: utf-8
class StructuresController < ApplicationController

  def show
    @structure      = Structure.find params[:id]
    @city           = @structure.city
    @places         = @structure.places
    @places_address = @places.to_gmaps4rails
    @courses        = @structure.courses.active
    @teachers       = @structure.teachers
    @medias         = @structure.medias
    @comments       = @structure.all_comments
    @comment        = @structure.comments.build
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
    structure_index = 0
    @json_place_addresses = @places.to_gmaps4rails do |place, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'><span>#{place_index}</span></a></div>"
                     })
      marker.title   place.name
      marker.json({ id: place.id })
    end
  end
end
