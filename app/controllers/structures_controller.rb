# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider
  include StructuresHelper

  respond_to :json

  layout :choose_layout

  def show
    @structure = Structure.friendly.find params[:id]
    @structure_decorator = @structure.decorate

    if params.has_key?(:bbox_ne) and params.has_key?(:bbox_sw)
      @place_ids = @structure.places_in_bounding_box(params[:bbox_sw], params[:bbox_ne]).map(&:id)
    elsif params.has_key?(:lat) and params.has_key?(:lng)
      @place_ids = @structure.places_around(params[:lat], params[:lng]).map(&:id)
    else
      @place_ids = @structure.places.map(&:id)
    end
    @header_promotion_title_for_structure = header_promotion_title_for_structure(@structure)
    @city      = @structure.city
    @medias    = (@structure.premium? ? @structure.medias.videos_first : @structure.medias.cover_first.limit(Media::FREE_PROFIL_LIMIT))

    @comments = @structure.comments.accepted.page(1).per(5)
    @model = StructureShowSerializer.new(@structure, {
      structure:          @structure,
      unlimited_comments: false,
      query:              get_filters_params,
      query_string:       request.env['QUERY_STRING'],
      place_ids:          @place_ids
    })
    @is_sleeping = @structure.is_sleeping
  end

  def contact_form
    @structure = Structure.friendly.find params[:id]
    render partial: 'structures/contact_form', locals: { is_xhr: true }
  end

  def jpo
    @structure = Structure.friendly.find params[:id]
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), status: 301 }
    end
  end

  def index
    @app_slug = "filtered-search"
    @subject = filter_by_subject?

    # We remove bbox parameters if user is on mobile since we don't show the map
    if mobile_device?
      params.delete :bbox_ne
      params.delete :bbox_sw
    end

    params[:address_name] ||= 'Paris, France' unless request.xhr?
    params[:page]          = 1 unless request.xhr?
    params[:per_page]      = 15

    if params_has_planning_filters?
      @structures, @places, @total = search_plannings
    else
      @structures, @total = search_structures
    end
    @latlng = retrieve_location
    @models = jasonify @structures

    if params[:name].present?
      # Log search terms
      SearchTermLog.create(name: params[:name]) unless cookies["search_term_logs_#{params[:name]}"].present?
      cookies["search_term_logs_#{params[:name]}"] = { value: params[:name], expires: 12.hours.from_now }
    end

    respond_to do |format|
      format.json do
        render json: @structures,
               root: 'structures',
               place_ids: @places,
               query: params,
               query_string: request.env['QUERY_STRING'],
               each_serializer: StructureSerializer,
               meta: { total: @total, location: @latlng }
      end

      # 'query' is the current query string, which allows us to direct users to
      # a filtered version of the structures show action
      format.html do
        @models = jasonify @structures, place_ids: @places, query: params, query_string: request.env['QUERY_STRING']
        cookies[:structure_search_path] = request.fullpath
      end
    end
  end

  def follow
    @structure = Structure.friendly.find params[:id]
    @structure.followings.create(user: current_user)
    AdminMailer.delay.user_is_now_following_you(@structure, current_user)
    Statistic.action(@structure.id, current_user, cookies[:fingerprint], request.ip, 'follow')
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: "Vous suivez désormais #{@structure.name}"}
    end
  end

  private

  def choose_layout
    if action_name == 'index'
      'search'
    else
      'users'
    end
  end
end
