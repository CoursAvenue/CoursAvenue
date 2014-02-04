# encoding: utf-8
class StructuresController < ApplicationController

  respond_to :json

  PLANNING_FILTERED_KEYS = ['audience_ids', 'level_ids', 'min_age_for_kids', 'max_price', 'min_price',
                            'price_type', 'max_age_for_kids', 'trial_course_amount', 'course_types',
                            'week_days', 'discount_types', 'start_date', 'end_date', 'start_hour', 'end_hour']

  layout :choose_layout

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
    @medias         = @structure.medias.videos_first.reject{ |media| media.type == 'Media::Image' and media.cover }
    @comments       = @structure.comments.accepted.reject(&:new_record?)
    @comment        = @structure.comments.build
    index           = 0
  end

  def filter_by_subject?
    params.delete(:subject_id) if params[:subject_id].blank?
    if params[:subject_id] == 'other'
      params[:other] = true
      params.delete(:subject_id)
    elsif params[:subject_id].present?
      @subject = Subject.friendly.find params[:subject_id]
    else
      # Little hack to determine if the name is equal a subject
      _name = params[:name]
      if _name.present? and Subject.where{name =~ _name}.any?
        @subject = Subject.where{name =~ _name}.first
      end
    end
  end

  def params_has_planning_filters?
    (params.keys & PLANNING_FILTERED_KEYS).any?
  end

  def search_plannings
    search          = PlanningSearch.search(params, group: :structure_id_str)
    structures      = search.group(:structure_id_str).groups.collect do |planning_group|
      planning_group.results.first.structure
    end
    total           = search.group(:structure_id_str).total

    [ structures, total ]
  end

  def search_structures
      # Else, can search per structure
      search           = StructureSearch.search(params)
      structures       = search.results
      total            = search.total

    [ structures, total ]
  end

  def retrieve_location
    StructureSearch.retrieve_location(params)
  end

  def retrieve_models
    @structures.map do |structure|
      StructureSerializer.new(structure, { root: false })
    end
  end

  def index
    filter_by_subject?

    params[:page] = 1 unless request.xhr?

    # If any of those key are in the params, then search per planning
    if params_has_planning_filters?
      @structures, @total = search_plannings
    else
      @structures, @total = search_structures
    end

    @latlng = retrieve_location
    @models = retrieve_models 

    if params[:name].present?
      # Log search terms
      SearchTermLog.create(name: params[:name]) unless cookies["search_term_logs_#{params[:name]}"].present?
      cookies["search_term_logs_#{params[:name]}"] = {value: params[:name], expires: 12.hours.from_now}
    end

    respond_to do |format|
      format.json { render json: @structures,
                           root: 'structures',
                           each_serializer: StructureSerializer,
                           meta: { total: @total, location: @latlng }}
      format.html do
        cookies[:structure_search_path] = request.fullpath
      end
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
