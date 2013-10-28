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
      @structure = Structure.friendly.find params[:id]
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
      @subject = Subject.friendly.find params[:subject_id]
    else
      # Little hack to determine if the name is equal a subject
      _name = params[:name]
      if _name.present? and Subject.where{name =~ _name}.any?
        @subject = Subject.where{name =~ _name}.first
      end
    end

    @structure_search      = StructureSearch.search(params)
    @structures            = @structure_search.results

    # the bbox params may come uri encoded as CSV
    if (params[:bbox_sw] && params[:bbox_ne])
      if (params[:bbox_sw].respond_to?(:split) && params[:bbox_ne].respond_to?(:split))
        params[:bbox_sw] = params[:bbox_sw].split(',');
        params[:bbox_ne] = params[:bbox_ne].split(',');
      end
      # TODO: To be removed when using Solr 4.
      # This is used because the bounding box refers to a circle and not a box...
      # Rejecting the structures that are not in the bounding box
      @structures.select! do |structure|
        structure.locations_in_bounding_box(params[:bbox_sw], params[:bbox_ne]).any?
      end
    end



    @latlng = StructureSearch.retrieve_location(params)

    respond_to do |format|
      format.json { render json: @structures, root: 'structures', each_serializer: StructureSerializer, meta: { total: @structure_search.total, location: @latlng }}
      format.html do
        cookies[:structure_search_path] = request.fullpath
      end
    end
    # fresh_when etag: [@places, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

end
