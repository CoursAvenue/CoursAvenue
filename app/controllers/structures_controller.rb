# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

  PLANNING_FILTERED_KEYS = %w(audience_ids level_ids min_age_for_kids max_price min_price price_type max_age_for_kids trial_course_amount course_types week_days discount_types start_date end_date start_hour end_hour)

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
    @courses        = @structure.courses.without_open_courses.active
    @teachers       = @structure.teachers
    @medias         = @structure.medias.videos_first
    @comments       = @structure.comments.accepted.reject(&:new_record?)
    @comment        = @structure.comments.build

    @model = (jasonify @structure, { unlimited_comments: true, query: query_string }).pop

    @tabs = [{
        icon: 'calendar',
        slug: 'courses',
        name: 'Courses'
      },
      {
        icon: '',
        slug: 'comments',
        name: 'Comments'
      },
      {
        icon: 'group',
        slug: 'teachers',
        name: 'Teachers'
      }
    ]

  end

  def jpo
    @structure = Structure.friendly.find params[:id]
    @city           = @structure.city
    @places         = @structure.courses.open_courses.map(&:places).flatten.uniq
    @teachers       = @structure.teachers
    @medias         = @structure.medias.videos_first.reject { |media| media.type == 'Media::Image' and media.cover }
    @comments       = @structure.comments.accepted.reject(&:new_record?)
    @comment        = @structure.comments.build

    respond_to do |format|
      if current_user or current_pro_admin
        format.html
      else
        format.html { redirect_to open_courses_path, alert: 'Vous devez vous enregistrer pour participer aux Portes Ouvertes des cours de loisirs'}
      end
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
               each_serializer: StructureSerializer,
               meta: { total: @total, location: @latlng }
      end
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
