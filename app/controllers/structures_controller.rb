# encoding: utf-8
class StructuresController < ApplicationController
  include StructuresHelper
  include ApplicationHelper

  skip_before_filter :verify_authenticity_token, only: [:add_to_favorite, :remove_from_favorite]

  before_filter :set_current_structure, except: [:index, :search, :typeahead,
                                                 :add_to_favorite, :remove_from_favorite,
                                                 :checkout_step_1_collection, :checkout_step_2_collection,
                                                 :checkout_step_3_collection, :checkout_step_4_collection]
  before_filter :authenticate_pro_admin!, only: [:toggle_pure_player]

  respond_to :json

  layout :get_layout

  def toggle_pure_player
    @structure.pure_player = (@structure.pure_player? ? false : true)
    @structure.save
    redirect_to structure_path(@structure)
  end

  def checkout_step_1_collection
  end

  def checkout_step_2_collection
    @subject   = Subject.find(params[:subject].present? ? params[:subject] : 'danse')
    if current_user
      if params[:gift].present?
        redirect_to checkout_step_3_collection_structures_path(city: (params[:city] || 'paris'), subject: params[:subject], groupe: params[:groupe], gift: true), error: 'Vous devez être connecté pour continuer.'
      else
        redirect_to checkout_step_3_collection_structures_path(city: (params[:city] || 'paris'), subject: params[:subject], groupe: params[:groupe]), error: 'Vous devez être connecté pour continuer.'
      end
    end
  end

  def checkout_step_3_collection
    @subject   = Subject.find(params[:subject].present? ? params[:subject] : 'danse')
    if current_user.nil?
      redirect_to checkout_step_1_collection_structures_path(subject: params[:subject], city: (params[:city] || 'paris')), error: 'Vous devez être connecté pour continuer.'
    else
      current_user.test_pass_subject = @subject.name
      current_user.test_pass_city    = params[:city] || 'paris'
      current_user.save
    end
  end

  def checkout_step_4_collection
    if current_user.nil?
      redirect_to checkout_step_1_collection_structures_path(subject: params[:subject], city: (params[:city] || 'paris')), error: 'Vous devez être connecté pour continuer.'
    else
      current_user.paid_for_pass = true
      current_user.save
    end
  end

  def checkout_step_1
    if current_user
      redirect_to checkout_step_2_structure_path(@structure, planning: params[:planning]), error: 'Vous devez être connecté pour continuer.'
    end
  end

  def checkout_step_2
    if params[:planning].present?
      @planning = @structure.plannings.find(params[:planning])
      @course   = @planning.course
    elsif params[:course].present?
      @course = @structure.courses.find(params[:course])
    end
    if current_user.nil?
      redirect_to checkout_step_1_structure_path(@structure), error: 'Vous devez être connecté pour continuer.'
    end
  end

  def checkout_step_3
    if current_user.nil? or params[:participation_request_id].blank?
      redirect_to checkout_step_1_structure_path(@structure), error: 'Vous devez être connecté pour continuer.'
    else
      @participation_request = @structure.participation_requests.find(params[:participation_request_id])
    end
  end

  # GET /etablissements/:id
  def show
    @structure_decorator  = @structure.decorate
    @serialized_structure = SmallStructureSerializer.new(@structure)
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
    # AdminMailer.delay(queue: 'mailers').user_is_now_following_you(@structure, current_user)
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
    if %(checkout_step_1 checkout_step_2 checkout_step_3 checkout_step_1_collection checkout_step_2_collection checkout_step_3_collection checkout_step_4_collection).include?(action_name)
      'empty'
    elsif action_name == 'reviews'
      'reservations/website'
    elsif action_name == 'index'
      'search'
    else
      'users'
    end
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
