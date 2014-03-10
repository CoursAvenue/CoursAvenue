# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

  PLANNING_FILTERED_KEYS = %w(audience_ids level_ids min_age_for_kids max_price min_price price_type max_age_for_kids trial_course_amount course_types week_days discount_types start_date end_date start_hour end_hour)

  layout :choose_layout

  def show
    
    begin
      @structure = Structure.friendly.find params[:id]
      @structure_decorator = @structure.decorate
      params[:structure_id] = @structure.id

      # use the structure's plannings unless we would filter the plannings
      if params_has_planning_filters?
        @planning_search = PlanningSearch.search(params)
        @plannings       = @planning_search.results
      else
        @plannings = @structure.plannings
      end
    rescue ActiveRecord::RecordNotFound
      place = Place.find params[:id]
      redirect_to structure_path(place.structure), status: 301
      return
    end

    # we need to group the plannings by course_id when we display them
    @planning_groups = {}
    @plannings.group_by(&:course_id).each do |course_id, plannings|
      @planning_groups[course_id] = plannings
    end

    # the default location is Paris, if no params were given
    @latlng         = retrieve_location
    if params[:lat].present? && params[:lng].present?
      @center         = { lat: params[:lat], lng: params[:lng] }
    else
      @center         = { lat: latlng[0], lng: latlng[1] }
    end

    @city           = @structure.city
    @places         = @structure.places
    @courses        = @structure.courses.without_open_courses.active
    @teachers       = @structure.teachers
    @medias         = @structure.medias.videos_first
    @comments       = @structure.comments.accepted.reject(&:new_record?)
    @comment        = @structure.comments.build

    @model = StructureShowSerializer.new(@structure, { unlimited_comments: true, query: query_string })

    @tabs = [{
        icon: 'calendar',
        slug: 'courses',
        name: 'Cours'
      },
      {
        icon: '',
        slug: 'comments',
        name: 'Avis'
      },
      {
        icon: 'group',
        slug: 'teachers',
        name: 'Professeurs'
      }
    ]

  end

  def jpo
    @structure    = Structure.friendly.find params[:id]
    @open_courses = @structure.courses.open_courses
    @city         = @structure.city
    @places       = @structure.courses.open_courses.map(&:places).flatten.uniq
    @teachers     = @structure.teachers
    @medias       = @structure.medias.videos_first.reject { |media| media.type == 'Media::Image' and media.cover }
    @comments     = @structure.comments.accepted.reject(&:new_record?)
    @comment      = @structure.comments.build
    respond_to do |format|
      format.html
    end
  end

  def index
    @app_slug = "filtered-search"
    @subject = filter_by_subject?

    params[:page] = 1 unless request.xhr?

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
               query: query_string,
               each_serializer: StructureSerializer,
               meta: { total: @total, location: @latlng }
      end

      # 'query' is the current query string, which allows us to direct users to
      # a filtered version of the structures show action
      format.html do
        @models = jasonify @structures, place_ids: @places, query: query_string
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

  def query_string
    request.env["QUERY_STRING"]
  end
end
