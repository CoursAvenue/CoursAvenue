class CourseGroupsController < ApplicationController
  include TimeParser

  def index
    params[:page] ||= 1
    @course_groups = CourseGroup

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
      when 'name'
        @course_groups = @course_groups.name_and_structure_name_contains(value, @course_groups) unless value.blank?

      when 'types'
        @course_groups = @course_groups.is_of_type(value, @course_groups)

      when 'price_specificities'
        @course_groups = @course_groups.has_price_specificities(value, @course_groups)

      when 'audiences'
        @course_groups = @course_groups.is_for_audience(value, @course_groups)

      when 'age'
        @course_groups = @course_groups.is_for_age(value, @course_groups) unless value.blank?

      when 'levels'
        level_ids = value.map(&:to_i)
        level_ids << Level.intermediate.id if level_ids.include? Level.average.id
        level_ids << Level.confirmed.id    if level_ids.include? Level.advanced.id
        @course_groups = @course_groups.is_for_level(level_ids, @course_groups)

      when 'week_days'
        @course_groups = @course_groups.that_happens(value, @course_groups)

      when 'time_slots'
        @course_groups = @course_groups.in_these_time_slots(value, @course_groups)

      when 'zip_codes'
        @course_groups = @course_groups.joins{structure}.where do
          value.map{ |zip_code| structure.zip_code == zip_code }.reduce(&:|)
        end

      when 'start_date'
        @course_groups = @course_groups.joins{plannings}.where{plannings.end_date >= Date.parse(value)}
      when 'end_date'
        @course_groups = @course_groups.joins{plannings}.where{plannings.start_date <= Date.parse(value)}

      when 'time_range'
        @course_groups = @course_groups.in_time_range(value[:min], value[:max], @course_groups)

      when 'price_range'
        @course_groups = @course_groups.in_price_range(value[:min], value[:max], @course_groups)
      end
    end
    # Group by id and order by first day in week
    @course_groups = @course_groups.joins{plannings}.group{id}.order('has_promotion DESC, has_online_payment DESC, min(plannings.week_day)')

    @course_groups = @course_groups.paginate(page: params[:page]).all

    @course_group_structures = @course_groups.collect{|course_group| course_group.structure}.uniq
    @course_group_structures.each do |structure|
      structure.geolocalize unless structure.is_geolocalized?
    end
    @json_structure_addresses = @course_group_structures.to_gmaps4rails do |structure, marker|
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
      format.html { @course_groups }
    end
  end

  def show
    @course_group = CourseGroup.find(params[:id])
    @structure    = @course_group.structure
    @plannings    = @course_group.courses.collect{ |course| course.planning }

    # @similar_courses = CourseGroup.where{} # With same discipline

    @json_courses = @course_group.courses.map{ |course| CourseSerializer.new(course, root: false) }.to_json

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
      format.json {render json: @course_group, serializer: CourseGroupSerializer}
    end

  end

end
