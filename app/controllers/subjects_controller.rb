class SubjectsController < ApplicationController

  before_filter :prepare_search

  def index
    search_solr
    init_geoloc

    respond_to do |format|
      format.html { @courses }
    end
  end


  def show
    @subject   = Subject.find(params[:id])
    city_id    = @city.id
    search_solr
    init_geoloc
    render action: 'index'
  end


  private

  def init_geoloc
    @course_structures = @courses.collect{|course| course.structure}.uniq

    # To remove
    @course_structures.each do |structure|
      structure.geolocalize unless structure.is_geolocalized?
    end
    structure_index = 0
    @json_structure_addresses = @course_structures.to_gmaps4rails do |structure, marker|
      structure_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='#'><span>#{structure_index}</span></a></div>"
                     })
      marker.title   structure.name
      marker.json({ id: structure.id })
    end
  end

  def prepare_search
    @city      = City.find(params[:city_id])
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

    @search = Sunspot.search(Course) do
      fulltext                              params[:name]                                           if params[:name].present?
      with :city,                           params[:city_id]
      with(:subject_ids).any_of             subject_ids                                             if params[:id]
      with(:type).any_of                    params[:types]                                          if params[:types].present?
      with(:audience_ids).any_of            params[:audiences]                                      if params[:audiences].present?
      with(:level_ids).any_of               level_ids                                               unless level_ids.empty?
      with :week_days,                      params[:week_days]                                      if params[:week_days].present?

      with(:min_age_for_kid).less_than      params[:age][:max]                                      if params[:age].present? and params[:age][:max].present?
      with(:max_age_for_kid).greater_than   params[:age][:min]                                      if params[:age].present? and params[:age][:min].present?

      with(:end_date).greater_than          params[:start_date]                                     if params[:start_date].present?
      with(:start_date).less_than           params[:end_date]                                       if params[:end_date].present?

      with(:start_time).greater_than        TimeParser.parse_time_string(params[:time_range][:min]) if params[:time_range].present? and params[:time_range][:min].present?
      with(:end_time).less_than             TimeParser.parse_time_string(params[:time_range][:max]) if params[:time_range].present? and params[:time_range][:max].present?

      with(:time_slots).any_of              params[:time_slots]                                     if params[:time_slots].present?

      with(:min_price).greater_than         params[:price_range][:min].to_i                         if params[:price_range].present? and params[:price_range][:min].present?
      with(:max_price).less_than            params[:price_range][:max].to_i                         if params[:price_range].present? and params[:price_range][:max].present?

      with(:zip_code).any_of                params[:zip_codes]                                      if params[:zip_codes].present?

      # TODO ------------------------------------------------------------------------------------------------------------------
      if params[:price_specificities].present?
        with :has_package_price,            true if params[:price_specificities].include?('has_package_price')
        with :has_trial_lesson,             true if params[:price_specificities].include?('has_trial_lesson')
        with :has_unit_course_price,        true if params[:price_specificities].include?('has_unit_course_price')
      end

      order_by :has_promotion, :desc
      order_by :is_promoted, :desc
      order_by :has_online_payment, :desc

      if params[:sort] == 'price_asc'
        order_by :min_price, :asc
      elsif 'price_desc'
        order_by :min_price, :desc
      end
      paginate :page => (params[:page] || 1), :per_page => 15
    end
    @courses = @search.results
  end
end
