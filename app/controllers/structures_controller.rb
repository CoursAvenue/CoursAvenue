# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider
  include StructuresHelper
  include ApplicationHelper

  skip_before_filter :verify_authenticity_token, only: [:add_to_favorite, :remove_from_favorite]

  before_filter :set_current_structure, except: [:index, :search, :typeahead]
  before_filter :authenticate_pro_admin!, only: [:toggle_pure_player]

  respond_to :json

  layout :get_layout

  def toggle_pure_player
    @structure.pure_player = (@structure.pure_player? ? false : true)
    @structure.save
    redirect_to structure_path(@structure)
  end

  # GET /etablissements
  # GET /paris
  # GET /danse--paris
  # GET /danse/danse-orientale--paris
  def index
    @city = City.find(params[:city_id]) rescue City.find('paris')
    proceed_to_redirection_if_needed
    if params[:root_subject_id].present? and params[:subject_id].blank?
      params[:subject_id] = params[:root_subject_id]
    end
    @app_slug = "filtered-search"
    @subject  = filter_by_subject?

    # We remove bbox parameters if user is on mobile since we don't show the map
    if mobile_device?
      params.delete :bbox_ne
      params.delete :bbox_sw
    end

    params[:address_name] ||= 'Paris, France' unless request.xhr?
    params[:page]         ||= 1
    params[:per_page]      = Structure::NB_STRUCTURE_PER_PAGE

    if params_has_planning_filters?
      @structures, @places, @total, @subject_slugs_with_more_than_five_results = search_plannings
    else
      @structures, @total, @subject_slugs_with_more_than_five_results = search_structures
    end
    @latlng = retrieve_location
    @models = jasonify @structures

    log_search

    @total_comments = Comment::Review.count
    @total_medias   = Media.count
    respond_to do |format|
      format.html do
        @models = jasonify @structures, place_ids: @places
        cookies[:structure_search_path] = request.fullpath
      end
      format.json do
        render json: @structures,
               root: 'structures',
               place_ids: @places,
               each_serializer: StructureSerializer,
               meta: { total: @total, location: @latlng }
      end
    end
  end

  # GET /etablissements/:id
  def show
    @structure_decorator = @structure.decorate
    @place_ids           = @structure.places.map(&:id)
    @city                = @structure.city

    @similar_profiles = @structure.similar_profiles(18)
    @medias = @structure.medias.cover_first.videos_first
    @model = StructureShowSerializer.new(@structure, {
      structure:          @structure,
      unlimited_comments: false,
      query:              get_filters_params,
      place_ids:          @place_ids
    })
    @is_sleeping = @structure.is_sleeping
  end

  # GET /etablissements/:id/portes-ouvertes-cours-loisirs
  # :nocov:
  def jpo
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), status: 301 }
    end
  end
  # :nocov:

  # Used for search on typeahead dropdown
  # GET /etablissements/search.json
  def search
    @structures = Rails.cache.fetch "StructuresController#search/#{params[:name]}" do
      StructureSearch.search(params).results
    end
    respond_to do |format|
      format.json do
        render json: @structures, each_serializer: StructureTypeaheadSerializer
      end
    end
  end

  # Used for search on typeahead dropdown
  # GET /etablissements/typeahead.json
  def typeahead
    @subjects = Rails.cache.fetch "structures/search/#{params[:name]}" do
      SubjectSearch.search(name: params[:name]).results
    end
    @structures = StructureSearch.search(params).results
    json_data = (@subjects + @structures).map do |data|
      if data.is_a? Structure
        StructureTypeaheadSerializer.new data
      else
        SubjectSearchSerializer.new data
      end
    end
    respond_to do |format|
      format.json do
        render json: json_data
      end
    end
  end

  # POST structure/:id/add_to_favorite
  # Create a following for the structure and the current_user
  def add_to_favorite
    @structure.followings.create(user: current_user)
    AdminMailer.delay.user_is_now_following_you(@structure, current_user)
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: "#{@structure.name} a été ajouté à vos favoris"}
      format.json { render json: { succes: true } }
    end
  end

  # POST structure/:id/remove_from_favorite
  # Destroy the existing following between the structure and the current_user
  def remove_from_favorite
    @structure.followings.where(user_id: current_user.id).first.try(:destroy)
    respond_to do |format|
      format.html { redirect_to user_followings_path(current_user), notice: "#{@structure.name} n'est plus dans vos favoris"}
      format.json { render json: { succes: true } }
    end
  end

  private

  def get_layout
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


  # Private: Set the current structure for the relevant routes
  # by fetching by its id or its slug.
  #
  # @return Structure
  def set_current_structure
    @structure = Structure.friendly.find(params[:id])
    if @structure.slug != params[:id]
      redirect_to structure_path(@structure), status: 301
    end
    raise ActiveRecord::RecordNotFound.new(params) if @structure.nil?
  end

  # We have cases where we need 301 redirections
  # This is due to old wrong links
  def proceed_to_redirection_if_needed
    # Catch URLs like cergy--2
    if params[:city_id] and params[:city_id].is_number?
      begin @city = City.find(params[:root_subject_id]); params[:root_subject_id] = nil rescue nil end if params[:root_subject_id].present?
      redirect_to structures_path_for_city_and_subject(@city, (params[:subject_id] || params[:root_subject_id])), status: 301
    elsif params[:page] and params[:page].is_negative_or_zero_number?
      redirect_to structures_path_for_city_and_subject(@city, (params[:subject_id] || params[:root_subject_id])), status: 301
    end
  end
end
