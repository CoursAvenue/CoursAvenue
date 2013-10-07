# encoding: utf-8
class StructuresController < ApplicationController
  respond_to :json

  def recommendation
    recommendation = '<p>' + params[:recommendation].gsub(/\r\n/, '</p><p>') + '</p>'
    name           = params[:name]
    email          = params[:email]
    # verify_recaptcha(params)
    if params[:recaptcha_response_field].present?
      StudentMailer.delay.recommend_structure(name, email, recommendation)
    end
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
    @courses        = @structure.courses.active
    @teachers       = @structure.teachers
    @medias         = @structure.medias
    @comments       = @structure.comments.accepted.reject(&:new_record?)
    @comment        = @structure.comments.build
    index           = 0
    @places_address = @structure.locations.to_gmaps4rails do |location, marker|
      index += 1
      marker.title   location.name
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'><span>#{index}</span></a></div>"
                     })
      marker.json({ id: location.id })
    end
  end

  def index
    if params[:subject_id]
      @subject = Subject.find params[:subject_id]
    else
      # Little hack to determine if the name is equal a subject
      _name = params[:name]
      if _name.present? and Subject.where{name =~ _name}.any?
        @subject = Subject.where{name =~ _name}.first
      end
    end

    @structures = StructureSearch.search(params).results

    ## ------------------------- Surrounding results
    # If there is less than 15 results, see surrounding structure (with same parent subject)
    if @structures.count < 15
      if @subject and @subject.grand_parent
        @parent_subject = @subject.grand_parent
        @other_structures = StructureSearch.search({lat: params[:lat] || 48.8540,
                                                    lng: params[:lng] || 2.3417,
                                                    radius: params[:radius] || 7,
                                                    sort: 'rating_desc',
                                                    has_logo: true,
                                                    per_page: 15 - @structures.count,
                                                    subject_id: @subject.parent.slug,
                                                    exclude: @subject.slug
                                                  })
        @other_structure_count = @other_structures.total
        @other_structures      = @other_structures.results
      end
    end
    ## ------------------------- Surrounding results
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
    radius               = (params[:radius] || 7).to_f
    @locations           = []
    @structure_locations = {} # Keeping in memory only locations that are in the radius
    @_structures         = @structures
    if @other_structures
      @_structures = @_structures + @other_structures
    end
    @_structures.each do |structure|
      @structure_locations[structure] = structure.locations_around(latitude, longitude, radius)
      @locations += @structure_locations[structure]
    end
    place_index = 0
    @json_structure_addresses = @locations.uniq.to_gmaps4rails do |location, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image disabled' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'></a></div>"
                     })
      marker.title   location.name
      marker.json({ id: location.id })
    end
  end
end
