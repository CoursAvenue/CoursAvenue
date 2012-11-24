class CoursesController < ApplicationController

  def index
    params[:page] ||= 1
    @courses = Course

    @audiences = Audience.all
    @levels    = Level.all


    unless params[:search].blank?
      params[:search].each do |key, value|
        case key
        when 'discipline'
          discipline_name  = value + '%'
          @courses         = @courses.joins{discipline}.where{discipline.name =~ discipline_name}
        when 'types'
          #type_name = (value == 'training' ? 'Course::Training' : 'Course::Lesson')
          types = []
          types << 'Course::Lesson' if value.include? 'lesson'
          types << 'Course::Training' if value.include? 'training'
          @courses         = @courses.where{type.like_any types}
        when 'audiences'
          @courses = @courses.joins{audiences}.where{audiences.name.like_any value}
        when 'levels'
          @courses = @courses.joins{levels}.where{levels.name.like_any value}
        when 'week_days'
          @courses = @courses.joins{planning}.where{planning.week_day.like_any value}
        when 'time_slots'
          time_slots = []
          value.each do |slot|
            start_time = parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:start_time]
            end_time   = parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:end_time]
            time_slots << [start_time, end_time]
          end
          @courses = @courses.joins{planning}.where do
            time_slots.map { |start_time, end_time| (plannings.start_time >= start_time) & (plannings.start_time <= end_time) }.reduce(&:|)
          end
        when 'price_range'
          @courses = @courses.joins{price}.where do
            (price.individual_course_price >= value[:min]) & (price.individual_course_price <= value[:max])
          end
        end
      end
    end
    @courses = @courses.paginate(page: params[:page]).all

    respond_to do |format|
      format.html { @courses }
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
