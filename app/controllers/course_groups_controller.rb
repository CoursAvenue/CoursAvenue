class CourseGroupsController < ApplicationController

  def index
    params[:page] ||= 1
    @course_groups = CourseGroup

    @audiences = Audience.all
    @levels    = Level.all


    params.each do |key, value|
      case key
      when 'name'
        course_name    = value + '%'
        @course_groups = @course_groups.where{name =~ course_name}
      #when 'types'
        # types = []
        # types << 'Course::Lesson'   if value.include? 'lesson'
        # types << 'Course::Training' if value.include? 'training'
        # @course_groups         = @course_groups.where{type.like_any types}
      when 'audiences'
        @course_groups = @course_groups.joins{audiences}.where{audiences.id.eq_any value.map(&:to_i)}
      when 'levels'
        @course_groups = @course_groups.joins{levels}.where{levels.id.eq_any value.map(&:to_i)}
      when 'week_days'
        #@course_groups = @course_groups.joins{plannings}.where{plannings.week_day.like_any value}
      when 'time_slots'
        time_slots = []
        value.each do |slot|
          start_time = parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:start_time]
          end_time   = parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:end_time]
          time_slots << [start_time, end_time]
        end
        @course_groups = @course_groups.joins{plannings}.where do
          time_slots.map { |start_time, end_time| (plannings.start_time >= start_time) & (plannings.start_time <= end_time) }.reduce(&:|)
        end
      #when 'price_range'
        # @course_groups = @course_groups.joins{price}.where do
        #   (price.individual_course_price >= value[:min]) & (price.individual_course_price <= value[:max])
        # end
      end
    end

    @course_groups = @course_groups.paginate(page: params[:page]).all

    respond_to do |format|
      format.html { @course_groups }
    end
  end

  def show
    @course = Course.find(params[:id])
  end

  private
  def parse_time_string time
    Time.parse("2000-01-01 #{time} UTC")
  end
end
