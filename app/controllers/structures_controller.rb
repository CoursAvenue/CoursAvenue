# encoding: utf-8
require 'new_relic/agent/method_tracer'
class StructuresController < ApplicationController
  include FilteredSearchProvider
  include StructuresHelper
  include ApplicationHelper
  include ::NewRelic::Agent::MethodTracer

  add_method_tracer :show, 'StructureController/show'
  add_method_tracer :index, 'StructureController/index'

  skip_before_filter :verify_authenticity_token, only: [:add_to_favorite, :remove_from_favorite]

  before_filter :set_current_structure, except: [:index, :search, :typeahead]

  respond_to :json

  layout :choose_layout

  # GET /etablissements
  # GET /paris
  # GET /danse--paris
  # GET /danse/danse-orientale--paris
  def index
    if params[:city_id]
      @city = City.find(params[:city_id])
    else
      @city = City.find('paris')
    end
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
    params[:per_page]      = 18

    if params_has_planning_filters?
      @structures, @places, @total = search_plannings
    else
      @structures, @total = search_structures
    end
    @latlng = retrieve_location
    @models = jasonify @structures

    log_search

    @total_comments = Comment::Review.count
    @total_medias   = Media.count
    respond_to do |format|
      format.html do
        @models = jasonify @structures, place_ids: @places, current_filtered_subject_name: @subject.try(:name)
        cookies[:structure_search_path] = request.fullpath
      end
      format.json do
        render json: @structures,
               root: 'structures',
               place_ids: @places,
               current_filtered_subject_name: @subject.try(:name),
               each_serializer: StructureSerializer,
               meta: { total: @total, location: @latlng }
      end
    end
  end

  # GET /etablissements/:id
  def show
    @structure_decorator                  = @structure.decorate
    @place_ids                            = @structure.places.map(&:id)
    @city                                 = @structure.city

    # Stopping stat. We have to find something else.
    # if !current_pro_admin
    #   Metric.delay(queue: 'metric').view(@structure.id, current_user, cookies[:fingerprint], request.ip)
    # end
    # if !@structure.premium?
    #   @similar_profiles = @structure.similar_profiles(21)
    #   if !current_pro_admin
    #     Metric.delay.print(@similar_profiles.map(&:id), current_user, cookies[:fingerprint], request.ip)
    #   end
    # end
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
    Metric.action(@structure.id, cookies[:fingerprint], request.ip, 'follow')
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


  # Private: Set the current structure for the relevant routes
  # by fetching by its id or its slug.
  #
  # @return Structure
  def set_current_structure
    @structure = Structure.fetch_by_id_or_slug(params[:id])
    raise ActiveRecord::RecordNotFound.new(params) if @structure.nil?
  end
end
