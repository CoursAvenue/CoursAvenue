# encoding: utf-8
class CoursesController < ApplicationController

  before_filter :prepare_search

  def index
    if @city.nil?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "La ville que vous recherchez n'existe pas" }
      end
    else
      search_solr
      init_geoloc
      cookies[:search_path] = request.fullpath
      respond_to do |format|
        format.html { @courses }
      end
    end
  end

  def show
    @course             = Course.find(params[:id])
    @comment            = @course.comments.build
    @comments           = @course.comments.order('created_at DESC').reject(&:new_record?)
    @city               = @course.city
    @structure          = @course.structure
    @place              = @course.place
    @plannings          = @course.plannings
    @subjects           = @course.subjects
    @has_promotion      = @course.has_promotion
    @has_nb_place       = @course.plannings.map(&:nb_place_available).compact.any?

    @similar_courses = @course.similar_courses

    @json_place_address = @place.to_gmaps4rails do |place, marker|
      marker.title   place.name
      marker.json({ id: place.id })
    end
    respond_to do |format|
      format.html
      format.json {render json: @course, serializer: CourseSerializer}
    end
  end

  private

  def init_geoloc
    @course_places = @courses.collect{|course| course.place}.uniq

    # To remove
    @course_places.each do |place|
      place.geolocalize unless place.is_geolocalized?
    end
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
    if params[:city].blank?
      if request.location.city.blank?
        city_term = 'paris'
      else
        city_term = request.location.city
      end
      city_slug = request.location.city
    else
      city_term  = "#{params[:city]}%"
      city_slug  = params[:city]
    end
    @city      = City.where{(slug == city_slug ) | (name =~ city_term)}.order('name ASC').first # Prevents from bad slugs
    @audiences = Audience.all
    @levels    = [
                    {name: Level.all_levels.name, id: Level.all_levels.id},
                    {name: Level.initiation.name, id: Level.initiation.id},
                    {name: Level.beginner.name, id: Level.beginner.id},
                    {name: 'level.average_intermediate', id: Level.intermediate.id},
                    {name: 'level.advanced_confirmed', id: Level.advanced.id},
                  ]
  end

  def search_solr
    if request.referrer == 'http://www.coursavenue.com/'
      if params[:time_slots].present? and params[:week_days].present?
        ClickLogger.create(name: 'Recherche avec créneau journée et horaire')
      elsif params[:time_slots].present?
        ClickLogger.create(name: 'Recherche avec créneau journée')
      elsif params[:week_days].present?
        ClickLogger.create(name: 'Recherche avec créneau horaire')
      else
        ClickLogger.create(name: 'Recherche')
      end
    end

    level_ids = []
    if params[:levels].present?
      level_ids = params[:levels].map(&:to_i)
      level_ids << Level.intermediate.id if level_ids.include? Level.average.id
      level_ids << Level.confirmed.id    if level_ids.include? Level.advanced.id
    end

    if params[:subject_id]
      @subject = Subject.find params[:subject_id]
    end
    city = @city

    params[:start_date] ||= I18n.l(Date.today)
    @search = Sunspot.search(Course) do
      fulltext                              params[:name]                                           if params[:name].present?
      with(:location).in_radius(city.latitude, city.longitude, params[:radius] || 10, :bbox => true)
      with(:subject_slugs).any_of           [params[:subject_id]]                                   if params[:subject_id]
      with(:type).any_of                    params[:types]                                          if params[:types].present?
      with(:audience_ids).any_of            params[:audiences]                                      if params[:audiences].present?
      with(:level_ids).any_of               level_ids                                               unless level_ids.empty?
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

      with(:approximate_price_per_course).greater_than         params[:price_range][:min].to_i                         if params[:price_range].present? and params[:price_range][:min].present?
      with(:approximate_price_per_course).less_than            params[:price_range][:max].to_i                         if params[:price_range].present? and params[:price_range][:max].present?

      # TODO ------------------------------------------------------------------------------------------------------------------
      if params[:price_specificities].present?
        with :has_package_price,            true if params[:price_specificities].include?('has_package_price')
        with :has_trial_lesson,             true if params[:price_specificities].include?('has_trial_lesson')
        with :has_unit_course_price,        true if params[:price_specificities].include?('has_unit_course_price')
      end
      with :active, true
      # order_by :has_promotion,       :desc
      # order_by :is_promoted,         :desc
      # order_by :has_online_payment,  :desc
      order_by :min_price, :asc

      if params[:sort] == 'price_asc'
        order_by :approximate_price_per_course, :asc
      elsif params[:sort] == 'price_desc'
        order_by :approximate_price_per_course, :desc
      elsif params[:sort] == 'rating_desc'
        order_by :rating, :desc
      end
      paginate :page => (params[:page] || 1), :per_page => 15
    end
    @courses = @search.results
  end
end
