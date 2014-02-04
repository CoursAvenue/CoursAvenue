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

  def open_courses
    redirect_to :action => 'index', :open_courses => true
  end

  def index
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

    params[:page] = 1 unless request.xhr?

    # If any of those key are in the params, then search per planning
    if (params.keys & PLANNING_FILTERED_KEYS).any?
      @planning_search = PlanningSearch.search(params, group: :structure_id_str)
      @structures      = @planning_search.group(:structure_id_str).groups.collect do |planning_group|
        planning_group.results.first.structure
      end
      @total           = @planning_search.group(:structure_id_str).total
    else
      # Else, can search per structure
      @structure_search = StructureSearch.search(params)
      @structures       = @structure_search.results
      @total            = @structure_search.total
    end

    # if (params[:bbox_sw] && params[:bbox_ne])
    #   # TODO: To be removed when using Solr 4.
    #   # This is used because the bounding box refers to a circle and not a box...
    #   # Rejecting the structures that are not in the bounding box
    #   @structures.select! do |structure|
    #     structure.locations_in_bounding_box(params[:bbox_sw], params[:bbox_ne]).any?
    #   end
    # end

    @latlng = StructureSearch.retrieve_location(params)
    @models = @structures.map do |structure|
      StructureSerializer.new(structure, { root: false })
    end

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
    # fresh_when etag: [@places, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
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
