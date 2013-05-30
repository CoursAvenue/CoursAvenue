# encoding: utf-8
class CoursesController < ApplicationController

  before_filter :prepare_search, only: [:show, :index]

  def index
    search_solr
    init_geoloc
    cookies[:search_path] = request.fullpath
    # fresh_when etag: [@courses, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

  def show
    @course             = Course.find(params[:id])
    unless @course.active
      redirect_to root_path, alert: "Ce cours n'est pas visible.", status: 301
    end
    @comment            = @course.comments.build
    @comments           = @course.comments.order('created_at DESC').reject(&:new_record?)
    @city               = @course.city
    @structure          = @course.structure
    @structure_comments = @structure.comments.order('created_at DESC')
    @place              = @course.place
    @plannings          = @course.plannings
    @subjects           = @course.subjects
    @has_promotion      = @course.has_promotion?
    @has_nb_place       = @course.plannings.map(&:nb_place_available).compact.any?
    @reservation        = Reservation.new
    @best_price         = @course.best_price
    @similar_courses    = @course.similar_courses

    @json_place_address = @place.to_gmaps4rails do |place, marker|
      marker.title   place.name
      marker.json({ id: place.id })
    end
    # fresh_when etag: [@course, @comments.first, ENV["ETAG_VERSION_ID"]], public: true
  end

  private

  def init_geoloc
    @course_places = @courses.collect{|course| course.place}.uniq
    place_index = 0
    @json_place_addresses = @course_places.to_gmaps4rails do |place, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='#'><span>#{place_index}</span></a></div>"
                     })
      marker.title   place.name
      marker.json({ id: place.id })
    end
  end

  def prepare_search
    if params[:lat].blank? or params[:lng].blank?
      if request.location and request.location.longitude != 0 and request.location.latitude != 0
        params[:lat] = request.location.latitude
        params[:lng] = request.location.longitude
      else
        # Setting paris lat & lng per default
        params[:lat] = 48.8592
        params[:lng] = 2.3417
      end
    end
    @audiences = Audience.all
    @levels    = Level.all
  end

  def search_solr
    if params[:subject_id]
      begin
        @subject = Subject.find params[:subject_id]
      rescue
        redirect_to courses_path, status: 301
      end
    end

    @search = Sunspot.search(Course) do
      fulltext                              params[:name]                                           if params[:name].present?
      with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 10, :bbox => true)
      with(:subject_slugs).any_of           [params[:subject_id]]                                   if params[:subject_id]
      with(:type).any_of                    params[:types]                                          if params[:types].present?
      with(:audience_ids).any_of            params[:audiences]                                      if params[:audiences].present?
      with(:level_ids).any_of               params[:levels]                                         if params[:levels].present?
      with :week_days,                      params[:week_days]                                      if params[:week_days].present?

      with(:min_age_for_kid).less_than      params[:age][:max]                                      if params[:age].present? and params[:age][:max].present?
      with(:max_age_for_kid).greater_than   params[:age][:min]                                      if params[:age].present? and params[:age][:min].present?

      with(:end_date).greater_than          params[:start_date]                                     if params[:start_date].present?
      with(:start_date).less_than           params[:end_date]                                       if params[:end_date].present?
      # with(:start_date).greater_than        params[:start_date]                                     if params[:end_date].present?
      # with(:end_date).less_than             params[:end_date]                                       if params[:start_date].present?

      with(:start_time).greater_than        TimeParser.parse_time_string(params[:time_range][:min]) if params[:time_range].present? and params[:time_range][:min].present?
      with(:end_time).less_than             TimeParser.parse_time_string(params[:time_range][:max]) if params[:time_range].present? and params[:time_range][:max].present?

      with(:time_slots).any_of              params[:time_slots]                                     if params[:time_slots].present?

      with(:approximate_price_per_course).greater_than         params[:price_range][:min].to_i      if params[:price_range].present? and params[:price_range][:min].present?
      with(:approximate_price_per_course).less_than            params[:price_range][:max].to_i      if params[:price_range].present? and params[:price_range][:max].present?

      with :active, true

      # order_by :has_promotion,       :desc
      # order_by :is_promoted,         :desc
      # order_by :has_online_payment,  :desc

      if params[:sort] == 'price_asc'
        order_by :approximate_price_per_course, :asc
      elsif params[:sort] == 'price_desc'
        order_by :approximate_price_per_course, :desc
      elsif params[:sort] == 'rating_desc'
        order_by :rating, :desc
        order_by :nb_comments, :desc
      else
        order_by_geodist(:location, params[:lat], params[:lng])
        order_by :has_comment, :desc
      end
      paginate :page => (params[:page] || 1), :per_page => 15
    end
    @courses = @search.results
  end
end
