class SubjectsController < ApplicationController

  before_filter :prepare_search

  def index
    # @courses   = @city.courses
    # search
    # paginate
    search_solr
    init_geoloc

    respond_to do |format|
      format.html { @courses }
    end
  end


  def show
    @subject   = Subject.find(params[:id])
    city_id    = @city.id
    if @subject.is_root?
      subject_ids = @subject.children.map(&:id)
      @courses    = Course.joins{subjects}.joins{structure}.where{(structure.city_id == city_id) & (subjects.id.eq_any subject_ids)}
    else
      @courses = @subject.courses.joins{structure}.where{structure.city_id == city_id}
    end
    search
    paginate
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

  def paginate
    # Group by id and order by first day in week
    case params[:sort]
    # min promotion because promotions are negative
    when 'price_asc'
      @courses = @courses.joins{prices}.joins{plannings}.group{id}.order('min(plannings.promotion) ASC, has_online_payment DESC, min(prices.amount) ASC')
    when 'price_desc'
      @courses = @courses.joins{prices}.joins{plannings}.group{id}.order('min(plannings.promotion) ASC, has_online_payment DESC, min(prices.amount) DESC')
    when 'date'
      @courses = @courses.joins{plannings}.group{id}.order('min(plannings.promotion) ASC, has_online_payment DESC, min(plannings.week_day)')
    else
      @courses = @courses.joins{plannings}.group{id}.order('min(plannings.promotion) ASC, has_online_payment DESC, min(plannings.week_day)')
    end
    @courses = @courses.page(params[:page]).per(15)

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
    @courses = Sunspot.search(Course) do
      fulltext            params[:name]
      with :city,         params[:city]
      with :audience_ids, params[:audiences]      if params[:audiences].present?
      with :level_ids,    params[:audiences]      if params[:levels].present?
      with :week_days,    params[:week_days]      if params[:week_days]

      paginate :page => params[:page], :per_page => 15
    end.results
  end

  def search
    params.each do |key, value|
      case key
      when 'city'
        @courses = @courses.from_city(value, @courses)

      when 'name'
        @courses = @courses.name_subjects_and_structure_name_contains(value, @courses) unless value.blank?

      when 'types'
        @courses = @courses.is_of_type(value, @courses)

      when 'price_specificities'
        @courses = @courses.has_price_specificities(value, @courses)

      when 'audiences'
        @courses = @courses.is_for_audience(value, @courses)

      when 'age'
        @courses = @courses.is_for_ages(value, @courses) unless value.blank?

      when 'levels'
        level_ids = value.map(&:to_i)
        if !level_ids.include? Level.all_levels.id
          level_ids << Level.intermediate.id if level_ids.include? Level.average.id
          level_ids << Level.confirmed.id    if level_ids.include? Level.advanced.id
          @courses  = @courses.is_for_level(level_ids, @courses)
        end

      when 'week_days'
        @courses = @courses.that_happens(value, @courses)

      when 'time_slots'
        @courses = @courses.in_these_time_slots(value, @courses)

      when 'zip_codes'
        @courses = @courses.joins{structure}.where do
          value.map{ |zip_code| structure.zip_code == zip_code }.reduce(&:|)
        end

      when 'start_date'
        @courses = @courses.joins{plannings}.where{plannings.end_date >= Date.parse(value)}
      when 'end_date'
        @courses = @courses.joins{plannings}.where{plannings.start_date <= Date.parse(value)}

      when 'time_range'
        @courses = @courses.in_time_range(value[:min], value[:max], @courses)

      when 'price_range'
        @courses = @courses.in_price_range(value[:min], value[:max], @courses)
      end
    end
  end

end
