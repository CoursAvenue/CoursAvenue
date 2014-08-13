# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider
  include StructuresHelper

  skip_before_filter :verify_authenticity_token, only: [:add_to_favorite, :remove_from_favorite]

  respond_to :json

  layout :choose_layout

  def show
    @structure = Structure.friendly.find params[:id]
    if @structure.is_sleeping?
      @structure.initialize_sleeping_attribute
    end
    @structure_decorator = @structure.decorate

    if params.has_key?(:bbox_ne) and params.has_key?(:bbox_sw)
      @place_ids = @structure.places_in_bounding_box(params[:bbox_sw], params[:bbox_ne]).map(&:id)
    elsif params.has_key?(:lat) and params.has_key?(:lng)
      if params[:radius]
        @place_ids = @structure.places_around(params[:lat], params[:lng], params[:radius].to_i).map(&:id)
      else
        @place_ids = @structure.places_around(params[:lat], params[:lng]).map(&:id)
      end
    else
      @place_ids = @structure.places.map(&:id)
    end
    @header_promotion_title_for_structure = header_promotion_title_for_structure(@structure)
    @city      = @structure.city
    @medias    = (@structure.premium? ? @structure.medias.cover_first.videos_first : @structure.medias.cover_first.limit(Media::FREE_PROFIL_LIMIT))
    @medias    = [] if @structure.is_sleeping?

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

  def jpo
    @structure = Structure.friendly.find params[:id]
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), status: 301 }
    end
  end

  def index
    if params[:root_subject_id].present? and params[:subject_id].blank?
      params[:subject_id] = params[:root_subject_id]
    end
    @app_slug = "filtered-search"
    @subject = filter_by_subject?

    # We remove bbox parameters if user is on mobile since we don't show the map
    if mobile_device?
      params.delete :bbox_ne
      params.delete :bbox_sw
    end

    params[:address_name] ||= 'Paris, France' unless request.xhr?
    params[:page]         ||= 1
    params[:per_page]      = 18

    if params_has_planning_filters?
      @structures, @places, @total = search_plannings
    else
      @structures, @total = search_structures
    end
    @latlng = retrieve_location
    @models = jasonify @structures

    log_search

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

  def add_to_favorite
    @structure = Structure.friendly.find params[:id]
    @structure.followings.create(user: current_user)
    AdminMailer.delay.user_is_now_following_you(@structure, current_user)
    Statistic.action(@structure.id, current_user, cookies[:fingerprint], request.ip, 'follow')
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: "#{@structure.name} a été ajouté à vos favoris"}
      format.json { render json: { succes: true } }
    end
  end

  def remove_from_favorite
    @structure = Structure.friendly.find params[:id]
    @structure.followings.where(user_id: current_user.id).first.try(:destroy)
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: "#{@structure.name} n'est plus dans vos favoris"}
      format.json { render json: { succes: true } }
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

  def log_search
    if params[:name].present?
      # Log search terms
      SearchTermLog.create(name: params[:name]) unless cookies["search_term_logs_#{params[:name]}"].present?
      cookies["search_term_logs_#{params[:name]}"] = { value: params[:name], expires: 12.hours.from_now }
    end
    SearchTermLog.create(name: "FILTRE: Age")           if params[:audience_ids].present? or params[:min_age_for_kids].present? or params[:max_age_for_kids].present?
    SearchTermLog.create(name: "FILTRE: Niveau")        if params[:level_ids].present?
    SearchTermLog.create(name: "FILTRE: Prix")          if params[:max_price].present? or params[:min_price].present?
    SearchTermLog.create(name: "FILTRE: Prix")          if params[:max_price].present? or params[:min_price].present? or params[:price_type].present?
    SearchTermLog.create(name: "FILTRE: Type de cours") if params[:course_types].present?
    SearchTermLog.create(name: "FILTRE: Dates")         if params[:week_days].present? or params[:start_date].present? or params[:end_date].present? or params[:start_hour].present? or params[:end_hour].present?
    SearchTermLog.create(name: "FILTRE: Promo")         if params[:discount_types].present?
    SearchTermLog.create(name: "FILTRE: Cours d'essai") if params[:trial_course_amount].present?
  end
end
