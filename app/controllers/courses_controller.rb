class CoursesController < ApplicationController
  include TimeParser

  def index
    params[:page] ||= 1
    @courses = Course

    @audiences = Audience.all
    @levels    = [
                    {name: Level.all_levels.name, id: Level.all_levels.id},
                    {name: Level.initiation.name, id: Level.initiation.id},
                    {name: Level.beginner.name, id: Level.beginner.id},
                    {name: 'level.average_intermediate', id: Level.intermediate.id},
                    {name: 'level.advanced_confirmed', id: Level.advanced.id},
                  ]

    params.each do |key, value|
      case key
      when 'city'
        @courses = @courses.from_city(value, @courses)

      when 'discipline'
        @courses = @courses.of_discipline(value, @courses)

      when 'name'
        @courses = @courses.name_and_structure_name_contains(value, @courses) unless value.blank?

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
        level_ids << Level.intermediate.id if level_ids.include? Level.average.id
        level_ids << Level.confirmed.id    if level_ids.include? Level.advanced.id
        @courses = @courses.is_for_level(level_ids, @courses)

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
    # Group by id and order by first day in week
    @courses = @courses.joins{plannings}.group{id}.order('has_promotion DESC, has_online_payment DESC, min(plannings.week_day)')

    @courses = @courses.page(params[:page]).per(15)

    @course_structures = @courses.collect{|course| course.structure}.uniq
    @course_structures.each do |structure|
      structure.geolocalize unless structure.is_geolocalized?
    end
    @json_structure_addresses = @course_structures.to_gmaps4rails do |structure, marker|
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<img width='25' src='#{ActionController::Base.helpers.image_path('icons/bulle.png')}'/>"
                     })
      marker.title   structure.name
      marker.json({ id: structure.id })
    end

    respond_to do |format|
      format.html { @courses }
    end
  end

  def show
    @course    = Course.find(params[:id])
    @structure       = @course.structure
    @plannings       = @course.plannings
    @disciplines     = @course.disciplines
    @discipline_name = (@course.disciplines.empty? ? t('all_discipline_route_name') : @course.disciplines.first.name)

    @similar_courses = @course.similar_courses

    @json_structure_address = @structure.to_gmaps4rails do |structure, marker|
      # marker.infowindow render_to_string(:partial => "/structures/my_template", :locals => { :object => structure})
      # marker.picture({
      #                 :picture => "http://www.placehold.it/32",
      #                 :width   => 32,
      #                 :height  => 32
      #                })
      marker.title   structure.name
      marker.json({ id: structure.id })
    end
    respond_to do |format|
      format.html
      format.json {render json: @course, serializer: CourseSerializer}
    end

  end

end
