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
        @course_groups = @course_groups.with_name_like(value)

      when 'types'
        @course_groups = @course_groups.is_of_type(value)

      when 'audiences'
        @course_groups = @course_groups.is_for_audience(value)

      when 'levels'
        level_ids = value.map(&:to_i)
        level_ids << Level.intermediate.id if level_ids.include? Level.average.id
        level_ids << Level.confirmed.id    if level_ids.include? Level.advanced.id
        @course_groups = @course_groups.is_for_level(level_ids)

      when 'week_days'
        @course_groups = @course_groups.that_happens(value)

      when 'time_slots'
        @course_groups = @course_groups.in_these_time_slots(value)

      when 'zip_codes'
        @course_groups = @course_groups.joins{structure}.where do
          value.map{ |zip_code| structure.zip_code == zip_code }.reduce(&:|)
        end

      when 'start_date'
        @course_groups = @course_groups.joins{plannings}.where{plannings.end_date >= Date.parse(value)}
      when 'end_date'
        @course_groups = @course_groups.joins{plannings}.where{plannings.start_date <= Date.parse(value)}

      when 'time_range'
        @course_groups = @course_groups.in_time_range(value[:min], value[:max])

      when 'price_range'
        @course_groups = @course_groups.in_price_range(value[:min], value[:max])
      end
    end
    # Eliminate all duplicates
    @course_groups = @course_groups.group{id}

    @course_groups = @course_groups.paginate(page: params[:page]).all

    respond_to do |format|
      format.html { @course_groups }
    end
  end

  def show
    @course_group         = CourseGroup.find(params[:id])
  end

end
