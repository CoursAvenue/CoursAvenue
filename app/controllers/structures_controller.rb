# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider
  include StructuresHelper

  skip_before_filter :verify_authenticity_token, only: [:add_to_favorite, :remove_from_favorite]
  before_filter :protect_discovery_pass_access, only: [:discovery_pass_search, :discovery_pass]

  respond_to :json

  layout :choose_layout

  # GET /paris
  # GET /danse--paris
  # GET /danse/danse-orientale--paris
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
               each_serializer: StructureSerializer,
               meta: { total: @total, location: @latlng }
      end

      # 'query' is the current query string, which allows us to direct users to
      # a filtered version of the structures show action
      format.html do
        @models = jasonify @structures, place_ids: @places, query: params
        cookies[:structure_search_path] = request.fullpath
      end
    end
  end

  # GET /etablissements/pass-decouverte
  def discovery_pass_search
    params[:discovery_pass] = true
    if params[:root_subject_id].present? and params[:subject_id].blank?
      params[:subject_id] = params[:root_subject_id]
    end
    @app_slug = "discovery-pass-search"
    @subject = filter_by_subject?

    # We remove bbox parameters if user is on mobile since we don't show the map
    if mobile_device?
      params.delete :bbox_ne
      params.delete :bbox_sw
    end

    params[:address_name] ||= 'Paris, France' unless request.xhr?
    params[:page]         ||= 1
    params[:per_page]      = 18

    # Always search on plannings
    @structures, @places, @total = search_plannings
    @latlng = retrieve_location
    @models = jasonify @structures

    log_search

    respond_to do |format|
      format.json do
        render json: @structures,
               root: 'structures',
               place_ids: @places,
               query: params,
               each_serializer: StructureDiscoveryPassSearchSerializer,
               meta: { total: @total, location: @latlng }
      end

      # 'query' is the current query string, which allows us to direct users to
      # a filtered version of the structures show action
      format.html do
        @models = jasonify @structures, place_ids: @places, query: params, serializer: StructureDiscoveryPassSearchSerializer
        cookies[:structure_search_path] = request.fullpath
      end
    end
  end

  # GET /etablissements/:id/pass-decouverte
  def discovery_pass
    @structure = Structure.friendly.find params[:id]
    @structure_decorator                  = @structure.decorate
    @header_promotion_title_for_structure = header_promotion_title_for_structure(@structure)
    @city                                 = @structure.city
    @medias                               = (@structure.premium? ? @structure.medias.cover_first.videos_first : @structure.medias.cover_first.videos_first.limit(Media::FREE_PROFIL_LIMIT))

    @place_ids = []
    place_search = PlanningSearch.search({ structure_id: @structure.id, discovery_pass: true }, group: :place_id_str)
    place_search.group(:place_id_str).groups.each do |place_group|
      @place_ids << place_group.value
    end
    @place_ids.compact!

    @model = StructureShowSerializer.new(@structure, {
      structure:          @structure,
      unlimited_comments: false,
      query:              { discovery_pass: true }, # Those params are passed to the backbone app
      place_ids:          @place_ids,
      discovery_pass:     true
    })
  end

  # GET /etablissements/:id
  def show
    @structure = Structure.friendly.find params[:id]
    if @structure.is_sleeping?
      @structure.initialize_sleeping_attributes
    end
    @structure_decorator                  = @structure.decorate
    @place_ids                            = @structure.places.map(&:id)
    @header_promotion_title_for_structure = header_promotion_title_for_structure(@structure)
    @city                                 = @structure.city
    if @structure.is_sleeping?
      @medias = []
    else
      @medias = (@structure.premium? ? @structure.medias.cover_first.videos_first : @structure.medias.cover_first.videos_first.limit(Media::FREE_PROFIL_LIMIT))
    end

    @model = StructureShowSerializer.new(@structure, {
      structure:          @structure,
      unlimited_comments: false,
      query:              get_filters_params,
      place_ids:          @place_ids
    })
    @is_sleeping = @structure.is_sleeping
  end

  # GET /etablissements/:id/portes-ouvertes-cours-loisirs
  def jpo
    @structure = Structure.friendly.find params[:id]
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), status: 301 }
    end
  end

  # Used for search on typeahead dropdown
  # GET /etablissements/:id/search.json
  def search
    @structures = StructureSearch.search(params).results
    respond_to do |format|
      format.json do
        render json: @structures, each_serializer: StructureTypeaheadSerializer
      end
    end

  end

  # POST structure/:id/add_to_favorite
  # Create a following for the structure and the current_user
  def add_to_favorite
    @structure = Structure.friendly.find params[:id]
    @structure.followings.create(user: current_user)
    AdminMailer.delay.user_is_now_following_you(@structure, current_user)
    Metric.action(@structure.id, current_user, cookies[:fingerprint], request.ip, 'follow')
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: "#{@structure.name} a été ajouté à vos favoris"}
      format.json { render json: { succes: true } }
    end
  end

  # POST structure/:id/remove_from_favorite
  # Destroy the existing following between the structure and the current_user
  def remove_from_favorite
    @structure = Structure.friendly.find params[:id]
    @structure.followings.where(user_id: current_user.id).first.try(:destroy)
    respond_to do |format|
      format.html { redirect_to user_followings_path(current_user), notice: "#{@structure.name} n'est plus dans vos favoris"}
      format.json { render json: { succes: true } }
    end
  end

  protected

  def layout_locals
    locals = { }
    locals[:top_menu_search_url] = discovery_pass_search_structures_path if action_name == 'discovery_pass_search'
    locals[:on_pass_pages]       = true if action_name == 'discovery_pass_search' or action_name == 'discovery_pass'
    locals
  end

  private

  def choose_layout
    if action_name == 'index' or action_name == 'discovery_pass_search'
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

  def protect_discovery_pass_access
    # Current_pro admin can see
    return if current_pro_admin
    # Users with pass can see
    return if current_user and current_user.discovery_pass and current_user.discovery_pass.active?
    redirect_to discovery_passes_path
  end
end
