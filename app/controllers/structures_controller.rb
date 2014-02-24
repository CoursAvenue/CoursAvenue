# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

<<<<<<< HEAD
=======
  PLANNING_FILTERED_KEYS = %w(audience_ids level_ids min_age_for_kids max_price min_price price_type max_age_for_kids trial_course_amount course_types week_days discount_types start_date end_date start_hour end_hour)

>>>>>>> staging
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
  end

  def jpo
    @structure = Structure.friendly.find params[:id]
    @city           = @structure.city
    @places         = @structure.courses.open_courses.map(&:places).flatten.uniq
    @teachers       = @structure.teachers
    @medias         = @structure.medias.videos_first.reject { |media| media.type == 'Media::Image' and media.cover }
    @comments       = @structure.comments.accepted.reject(&:new_record?)
    @comment        = @structure.comments.build

    @model = (jasonify @structure, { unlimited_comments: true }).pop

    # data for the tabs manager
    # TODO we want to be able to choose between JSTemplate or haml
    # served from rails
    @structure_tabs_manager = {
      view: "TabManager",
      tabs: ['courses.calendar', 'comments', 'teachers.group', ''],
      bootstrap: @model.to_json,
      provides: "structure"
    }

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

  def index
    @app_slug = "filtered-search"
    @subject = filter_by_subject?

    params[:page] = 1 unless request.xhr?

    if params_has_planning_filters?
<<<<<<< HEAD
      @structures, @total = search_plannings
=======
      @structures, @places, @total = search_plannings
>>>>>>> staging
    else
      @structures, @total = search_structures
    end

    @latlng = retrieve_location
<<<<<<< HEAD
    @models = jasonify @structures
=======
>>>>>>> staging

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
        @models = jasonify @structures, place_ids: @places
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
