# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider
  include StructuresHelper
  include ApplicationHelper

  skip_before_filter :verify_authenticity_token, only: [:add_to_favorite, :remove_from_favorite]

  before_filter :set_current_structure, except: [:index, :search, :typeahead, :add_to_favorite, :remove_from_favorite]
  before_filter :authenticate_pro_admin!, only: [:toggle_pure_player]

  respond_to :json

  layout :get_layout

  def toggle_pure_player
    @structure.pure_player = (@structure.pure_player? ? false : true)
    @structure.save
    redirect_to structure_path(@structure)
  end

  # GET /etablissements/:id
  def show
    @structure_decorator  = @structure.decorate
    @serialized_structure = StructureSerializer.new(@structure)
    @city                 = @structure.city

    if current_user
      @favorited = current_user.favorites.structures.where(structure_id: @structure.id).present?
    else
      @favorited = false
    end

    @medias = @structure.medias.cover_first.videos_first
    @is_sleeping = @structure.is_sleeping
  end

  # POST structure/:id/add_to_favorite
  # Create a following for the structure and the current_user
  def add_to_favorite
    @structure = Structure.find(params[:id])
    @structure.user_favorites.create(user: current_user)
    # AdminMailer.delay.user_is_now_following_you(@structure, current_user)
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: "#{@structure.name} a été ajouté à vos favoris"}
      format.json { render json: { succes: true } }
    end
  end

  # POST structure/:id/remove_from_favorite
  # Destroy the existing following between the structure and the current_user
  def remove_from_favorite
    @structure = Structure.find(params[:id])
    @structure.user_favorites.where(user_id: current_user.id).first.try(:destroy)
    respond_to do |format|
      format.html { redirect_to user_followings_path(current_user), notice: "#{@structure.name} n'est plus dans vos favoris"}
      format.json { render json: { succes: true } }
    end
  end

  def reviews
    @reviews = @structure.comments
  end

  private

  def get_layout
    if action_name == 'reviews'
      'structure_websites/website'
    elsif action_name == 'index'
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
