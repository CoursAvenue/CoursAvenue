class SubjectsController < ApplicationController

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
    if @city.nil?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "La ville que vous recherchez n'existe pas" }
      end
    else
    @subject        = Subject.find(params[:id])
    @parent_subject = @subject.parent || @subject
    cookies[:search_path] = request.fullpath
    city_id         = @city.id
    search_solr
    init_geoloc
      render action: 'index'
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
    level_ids = []
    if params[:levels].present?
      level_ids = params[:levels].map(&:to_i)
      #unless level_ids.include? Level.all_levels.id
        level_ids << Level.intermediate.id if level_ids.include? Level.average.id
        level_ids << Level.confirmed.id    if level_ids.include? Level.advanced.id
      #end
    end
    if params[:id]
      if @subject.is_root?
        subject_ids = @subject.children.map(&:id)
      else
        subject_ids = [@subject.id]
      end
    end
    city = @city
    @search = Sunspot.search(Course) do
      fulltext                              params[:name]                                           if params[:name].present?
      with(:location).in_radius(city.latitude, city.longitude, params[:radius] || 10, :bbox => true)
      #with :city,                           params[:city]
      with(:subject_ids).any_of             subject_ids                                             if params[:id]
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

      with(:zip_code).any_of                params[:zip_codes]                                      if params[:zip_codes].present?

      # TODO ------------------------------------------------------------------------------------------------------------------
      if params[:price_specificities].present?
        with :has_package_price,            true if params[:price_specificities].include?('has_package_price')
        with :has_trial_lesson,             true if params[:price_specificities].include?('has_trial_lesson')
        with :has_unit_course_price,        true if params[:price_specificities].include?('has_unit_course_price')
      end
      with :active, true
      order_by :has_promotion,       :desc
      order_by :is_promoted,         :desc
      order_by :has_online_payment,  :desc
      order_by :has_no_price,        :asc

      if params[:sort] == 'price_asc'
        order_by :approximate_price_per_course, :asc
      elsif 'price_desc'
        order_by :approximate_price_per_course, :desc
      end
      paginate :page => (params[:page] || 1), :per_page => 15
    end
    @courses = @search.results
  end
end
